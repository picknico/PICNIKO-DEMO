import { getDb } from './db.js';

export async function requireUser(){
  const db=getDb();
  if(!db) throw new Error('Supabase not configured');
  const {data,error}=await db.auth.getUser();
  if(error) throw error;
  if(!data.user) throw new Error('LOGIN_REQUIRED');
  return {db,user:data.user};
}

export function esc(v){return String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));}
export function toast(msg){
  let t=document.getElementById('v32Toast');
  if(!t){t=document.createElement('div');t.id='v32Toast';t.style.cssText='position:fixed;left:50%;bottom:86px;transform:translateX(-50%);z-index:9999;background:#07152e;color:#fff;padding:12px 16px;border-radius:999px;box-shadow:0 10px 30px #0004;font-weight:700;font-size:13px;max-width:90vw;text-align:center';document.body.appendChild(t)}
  t.textContent=msg;t.hidden=false;clearTimeout(t._x);t._x=setTimeout(()=>t.hidden=true,2600);
}

// ---------- CONNECT: uses the already-approved production friend_requests RPCs ----------
export async function discoverPeople(search=''){
  const {db}=await requireUser();
  return db.rpc('discover_message_users',{p_search:search||''});
}
export async function friendStatus(userId){
  const {db}=await requireUser();
  return db.rpc('get_friend_status',{p_other_user_id:userId});
}
export async function sendConnect(userId){
  const {db}=await requireUser();
  return db.rpc('send_friend_request',{p_recipient_id:userId});
}
export async function respondConnect(requestId,action){
  const {db}=await requireUser();
  return db.rpc('respond_friend_request',{p_request_id:requestId,p_action:action});
}

// ---------- REELS ----------
export async function listReels(limit=30){
  const {db}=await requireUser();
  const q=await db.from('picniko_reels').select('*,profiles:author_id(id,full_name,city)').eq('status','published').order('created_at',{ascending:false}).limit(limit);
  if(q.error) return q;
  const rows=q.data||[];
  if(!rows.length) return q;
  const e=await db.rpc('picniko_get_reel_engagements',{p_reel_ids:rows.map(r=>r.id)});
  if(e.error) return {data:rows,error:null,engagementError:e.error};
  const map=new Map((e.data||[]).map(x=>[x.reel_id,x]));
  return {...q,data:rows.map(r=>({...r,engagement:map.get(r.id)||{like_count:0,comment_count:0,save_count:0,liked:false,saved:false}}))};
}

export async function createReel({file,caption,hashtags=[],locationName=''}){
  const {db,user}=await requireUser();
  if(!file) throw new Error('VIDEO_REQUIRED');
  const safe=file.name.replace(/[^a-zA-Z0-9._-]/g,'_');
  const path=`${user.id}/${crypto.randomUUID()}-${safe}`;
  const up=await db.storage.from('reel-media').upload(path,file,{contentType:file.type||'video/mp4',upsert:false});
  if(up.error) throw up.error;
  const pub=db.storage.from('reel-media').getPublicUrl(path).data.publicUrl;
  const ins=await db.from('picniko_reels').insert({author_id:user.id,video_path:path,caption:caption||null,hashtags,location_name:locationName||null}).select().single();
  if(ins.error){await db.storage.from('reel-media').remove([path]);throw ins.error;}
  return {...ins,publicUrl:pub};
}
export async function toggleReelLike(reelId){
  const {db,user}=await requireUser();
  const q=await db.from('picniko_reel_likes').select('reel_id').eq('reel_id',reelId).eq('user_id',user.id).maybeSingle();
  if(q.error) return q;
  if(q.data){
    const x=await db.from('picniko_reel_likes').delete().eq('reel_id',reelId).eq('user_id',user.id);
    return {...x,liked:false};
  }
  const x=await db.from('picniko_reel_likes').insert({reel_id:reelId,user_id:user.id});
  return {...x,liked:true};
}

export async function toggleReelSave(reelId){
  const {db,user}=await requireUser();
  const q=await db.from('picniko_reel_saves').select('reel_id').eq('reel_id',reelId).eq('user_id',user.id).maybeSingle();
  if(q.error) return q;
  if(q.data){
    const x=await db.from('picniko_reel_saves').delete().eq('reel_id',reelId).eq('user_id',user.id);
    return {...x,saved:false};
  }
  const x=await db.from('picniko_reel_saves').insert({reel_id:reelId,user_id:user.id});
  return {...x,saved:true};
}

export async function reelComments(reelId){const {db}=await requireUser();return db.from('picniko_reel_comments').select('*,profiles:user_id(id,full_name)').eq('reel_id',reelId).order('created_at',{ascending:true})}
export async function addReelComment(reelId,body){const {db,user}=await requireUser();return db.from('picniko_reel_comments').insert({reel_id:reelId,user_id:user.id,body:body?.trim()||''}).select().single()}

// ---------- GROUPS ----------
export async function listGroups(){const {db}=await requireUser();return db.from('picniko_groups').select('*').eq('visibility','public').order('created_at',{ascending:false})}
export async function createGroup(name,description,visibility='public'){
  const {db,user}=await requireUser();
  const g=await db.from('picniko_groups').insert({owner_id:user.id,name:name.trim(),description:description?.trim()||null,visibility}).select().single();
  if(g.error) throw g.error;
  const m=await db.from('picniko_group_members').insert({group_id:g.data.id,user_id:user.id,role:'owner',status:'active'});
  if(m.error) throw m.error;
  return g;
}
export async function joinGroup(groupId){const {db,user}=await requireUser();return db.from('picniko_group_members').upsert({group_id:groupId,user_id:user.id,role:'member',status:'active'},{onConflict:'group_id,user_id'});}
export async function groupMembers(groupId){const {db}=await requireUser();return db.from('picniko_group_members').select('*,profiles:user_id(id,full_name,city)').eq('group_id',groupId).eq('status','active').order('joined_at',{ascending:true})}
export async function groupPosts(groupId){const {db}=await requireUser();return db.from('picniko_group_posts').select('*,profiles:author_id(id,full_name)').eq('group_id',groupId).order('created_at',{ascending:false}).limit(50)}
export async function addGroupPost(groupId,body){const {db,user}=await requireUser();return db.from('picniko_group_posts').insert({group_id:groupId,author_id:user.id,body:body.trim()}).select().single()}

// ---------- NEWS ----------
export async function listNews(search=''){const {db}=await requireUser();let q=db.from('picniko_news').select('*').eq('status','published').order('published_at',{ascending:false}).limit(50);if(search.trim()) q=q.or(`title.ilike.%${search.trim()}%,summary.ilike.%${search.trim()}%,city.ilike.%${search.trim()}%,category.ilike.%${search.trim()}%`);return q;}
export async function toggleNewsBookmark(newsId){const {db,user}=await requireUser();const q=await db.from('picniko_news_bookmarks').select('news_id').eq('news_id',newsId).eq('user_id',user.id).maybeSingle();if(q.error)return q;if(q.data)return db.from('picniko_news_bookmarks').delete().eq('news_id',newsId).eq('user_id',user.id);return db.from('picniko_news_bookmarks').insert({news_id:newsId,user_id:user.id});}

// ---------- MARKETPLACE ----------
export async function listMarketplace(search=''){const {db}=await requireUser();let q=db.from('picniko_marketplace_listings').select('*,profiles:seller_id(id,full_name,city)').eq('status','active').order('created_at',{ascending:false}).limit(50);if(search.trim()) q=q.or(`title.ilike.%${search.trim()}%,description.ilike.%${search.trim()}%,category.ilike.%${search.trim()}%,city.ilike.%${search.trim()}%`);return q;}
export async function createListing({title,description,category,price,stockQuantity=0,city=''}){const {db,user}=await requireUser();return db.from('picniko_marketplace_listings').insert({seller_id:user.id,title:title.trim(),description:description?.trim()||null,category:category?.trim()||null,price:Number(price||0),stock_quantity:Number(stockQuantity||0),city:city?.trim()||null}).select().single()}
export async function toggleFavorite(listingId){const {db,user}=await requireUser();const q=await db.from('picniko_marketplace_favorites').select('listing_id').eq('listing_id',listingId).eq('user_id',user.id).maybeSingle();if(q.error)return q;if(q.data)return db.from('picniko_marketplace_favorites').delete().eq('listing_id',listingId).eq('user_id',user.id);return db.from('picniko_marketplace_favorites').insert({listing_id:listingId,user_id:user.id});}
export async function inquireListing(listingId,message){const {db,user}=await requireUser();return db.from('picniko_marketplace_inquiries').insert({listing_id:listingId,buyer_id:user.id,message:message.trim()}).select().single()}
