const modal=document.getElementById('modal');
const wizard=document.getElementById('wizard');
const supa=window.supabase;
const cfg=window.PICNIKO_CONFIG||{};
let client=null;
if(supa?.createClient && cfg.SUPABASE_URL && cfg.SUPABASE_ANON_KEY){client=supa.createClient(cfg.SUPABASE_URL,cfg.SUPABASE_ANON_KEY)}

const state={step:1,goal:'messages',name:'',location:'Pune',radius:25,age:'18–45',interests:['Travel','Food'],budget:500,creative:{headline:'Weekend escape near Pune',body:'Discover a refreshing getaway with your friends.',cta:'Learn more',description:'',hashtags:['#PICNIKO','#Travel','#Pune'],keywords:['Pune travel','weekend getaway','picnic near Pune'],media:null,aiBoost:null},channels:['picniko'],campaignId:null,saving:false};
const goals=[['messages','💬','More messages'],['leads','👤','More leads'],['traffic','🌐','Website visits'],['sales','🛍','More sales'],['video_views','▶','Video views'],['local_visits','📍','Local visits'],['awareness','✨','Brand awareness']];
const channelMeta={picniko:['P','PICNIKO Ads','Local discovery • social • offers'],google:['G','Google Ads','Search • YouTube • Display'],meta:['M','Meta Ads','Facebook • Instagram']};
function esc(v){return String(v??'').replace(/[&<>'"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]))}
function openWizard(){state.step=1;state.campaignId=null;state.name='';state.goal='messages';state.channels=['picniko'];render()}
function closeWizard(){modal.classList.remove('show')}
document.getElementById('createBtn').onclick=()=>{modal.classList.add('show');openWizard()};
document.getElementById('close').onclick=closeWizard;
modal.addEventListener('click',e=>{if(e.target===modal)closeWizard()});
document.getElementById('aiBtn').onclick=()=>{modal.classList.add('show');state.step=2;state.name='PIKO Smart Campaign';state.goal='local_visits';state.location='Pune';state.radius=25;state.interests=['Travel','Food','Photography'];render()};

document.querySelectorAll('.connect').forEach(b=>b.onclick=()=>alert('Connection setup is ready for OAuth. The actual Google/Meta authorization will be added server-side after the business explicitly authorizes the connection.'));

document.querySelectorAll('.goals button').forEach(b=>b.onclick=()=>{state.goal=(b.textContent.includes('Leads')?'leads':b.textContent.includes('Website')?'traffic':b.textContent.includes('Sales')?'sales':b.textContent.includes('Video')?'video_views':b.textContent.includes('Local')?'local_visits':'messages');modal.classList.add('show');state.step=1;render()});

document.querySelectorAll('.nav').forEach((b,i)=>b.onclick=()=>{document.querySelectorAll('.nav').forEach(x=>x.classList.remove('active'));b.classList.add('active');if(i===1)loadCampaigns()});

function render(){
 const steps=['Goal','Audience','Creative','Channels','Review','Done'];
 const progress=steps.slice(0,5).map((x,i)=>`<span class="wiz-step ${state.step===i+1?'active':''} ${state.step>i+1?'done':''}">${i+1} ${x}</span>`).join('<i>›</i>');
 let body='';
 if(state.step===1) body=`<div class="eyebrow">STEP 1 • OBJECTIVE</div><h2>What should this campaign achieve?</h2><p class="wiz-muted">Start with the outcome. PICNIKO will shape the audience and creative around it.</p><div class="wiz-goals">${goals.map(g=>`<button class="wiz-goal ${state.goal===g[0]?'selected':''}" data-goal="${g[0]}"><b>${g[1]}</b><span>${g[2]}</span><small>${g[0]==='local_visits'?'Drive nearby discovery':g[0]==='messages'?'Start conversations':'Build measurable action'}</small></button>`).join('')}</div>`;
 if(state.step===2) body=`<div class="eyebrow">STEP 2 • AUDIENCE</div><h2>Who should see it?</h2><p class="wiz-muted">Use clear, user-controlled targeting. Private messages and exact private locations are never targeting inputs.</p><div class="wiz-form"><label>Campaign name<input id="wName" value="${esc(state.name)}" placeholder="e.g. Pune Weekend Offer"></label><label>Location<input id="wLoc" value="${esc(state.location)}"></label><label>Radius<select id="wRadius">${[5,10,25,50,100].map(x=>`<option ${Number(state.radius)===x?'selected':''}>${x}</option>`).join('')}</select></label><label>Age<select id="wAge"><option ${state.age==='18–45'?'selected':''}>18–45</option><option ${state.age==='21–55'?'selected':''}>21–55</option><option ${state.age==='25–65+'?'selected':''}>25–65+</option></select></label><label class="full">Interests<input id="wInterests" value="${esc(state.interests.join(', '))}" placeholder="Travel, Food, Photography"></label><label>Daily budget (₹)<input id="wBudget" type="number" min="1" value="${Number(state.budget)||500}"></label></div><div class="smart-note">✦ PIKO suggestion: Keep the first campaign focused on one clear audience and one conversion goal.</div>`;
 if(state.step===3) body=`<div class="eyebrow">STEP 3 • CREATIVE + AI BOOST</div><h2>Build an ad people want to notice</h2><p class="wiz-muted">Upload an image/video, write your message, then use PIKO AI Boost to generate stronger copy, hashtags and search keywords for each channel.</p><div class="creative-editor"><label>Image / Video<input id="wMedia" type="file" accept="image/*,video/*"><small class="field-hint">JPG, PNG, WEBP, MP4, MOV • max 25 MB</small></label><div id="mediaPreview" class="media-preview">${state.creative.media?.previewUrl? (state.creative.media.type?.startsWith('video/')?`<video src="${esc(state.creative.media.previewUrl)}" controls playsinline></video>`:`<img src="${esc(state.creative.media.previewUrl)}" alt="Ad creative preview">`) : '<span>📷 Your creative preview appears here</span>'}</div><label>Headline<input id="wHeadline" value="${esc(state.creative.headline)}" maxlength="80"></label><label>Description / Primary text<textarea id="wBody" maxlength="500">${esc(state.creative.body)}</textarea></label><label>Call to action<select id="wCta"><option ${state.creative.cta==='Learn more'?'selected':''}>Learn more</option><option ${state.creative.cta==='Book now'?'selected':''}>Book now</option><option ${state.creative.cta==='Send message'?'selected':''}>Send message</option><option ${state.creative.cta==='Get offer'?'selected':''}>Get offer</option></select></label><label>Hashtags<input id="wHashtags" value="${esc((state.creative.hashtags||[]).join(' '))}" placeholder="#PICNIKO #Pune #Travel"></label><label>Ad keywords<input id="wKeywords" value="${esc((state.creative.keywords||[]).join(', '))}" placeholder="Pune weekend trip, picnic near Pune..."></label><div class="ai-boost"><div><b>✦ PIKO AI Boost</b><small>Improve headline, description, CTA, hashtags and keywords. Never auto-publishes.</small></div><button type="button" class="primary" id="aiBoostBtn">Boost ad with PIKO →</button></div><div id="aiBoostResult" class="ai-boost-result"></div></div><div class="creative-live"><div id="creativeMediaLive" class="creative-img">PICNIKO<br>AD</div><div><small>LIVE PREVIEW</small><h3>${esc(state.creative.headline)}</h3><p>${esc(state.creative.body)}</p><div class="tag-row">${(state.creative.hashtags||[]).slice(0,5).map(x=>`<span>${esc(x)}</span>`).join('')}</div><button>${esc(state.creative.cta)}</button></div></div>`;
 if(state.step===4) body=`<div class="eyebrow">STEP 4 • CHANNELS</div><h2>Where should it run?</h2><p class="wiz-muted">One campaign brief. Multiple destinations. Actual Google/Meta publishing requires an authorized connected account.</p><div class="channel-grid">${Object.entries(channelMeta).map(([k,v])=>`<button class="channel-choice ${state.channels.includes(k)?'selected':''}" data-channel="${k}"><span class="channel-icon">${v[0]}</span><span><b>${v[1]}</b><small>${v[2]}</small></span><strong>${state.channels.includes(k)?'✓':'+'}</strong></button>`).join('')}</div><div class="budget-summary"><span>Daily budget</span><b>₹${Number(state.budget||0).toLocaleString('en-IN')}</b><small>Can be adjusted before launch.</small></div>`;
 if(state.step===5) body=`<div class="eyebrow">STEP 5 • REVIEW</div><h2>Ready to save your campaign?</h2><p class="wiz-muted">Review everything before creating the campaign record.</p><div class="review-grid"><div><small>OBJECTIVE</small><b>${goals.find(g=>g[0]===state.goal)?.[2]||state.goal}</b></div><div><small>CAMPAIGN</small><b>${esc(state.name||'Untitled campaign')}</b></div><div><small>AUDIENCE</small><b>${esc(state.location)} • ${state.radius} km • ${esc(state.age)}</b></div><div><small>INTERESTS</small><b>${esc(state.interests.join(', '))}</b></div><div><small>DAILY BUDGET</small><b>₹${Number(state.budget||0).toLocaleString('en-IN')}</b></div><div><small>CHANNELS</small><b>${state.channels.map(c=>channelMeta[c][1]).join(' • ')}</b></div></div><div id="saveStatus" class="save-status"></div>`;
 if(state.step===6) body=`<div class="success-mark">✓</div><div class="eyebrow">CAMPAIGN CREATED</div><h2>Your campaign is saved.</h2><p class="wiz-muted">It is now available as a draft/review item. Google and Meta publishing remains gated until the respective account is authorized.</p><div class="success-actions"><button class="primary" id="doneBtn">Back to studio</button></div>`;
 wizard.innerHTML=`<div class="wiz-head"><div><div class="wiz-title">Create campaign</div><div class="wiz-progress">${progress}</div></div><span class="wiz-safe">● Secure workspace</span></div><div class="wiz-body">${body}</div><div class="wiz-foot">${state.step>1&&state.step<6?'<button class="ghost" id="backBtn">← Back</button>':'<span></span>'}<div class="wiz-actions">${state.step<5?'<button class="primary" id="nextBtn">Continue →</button>':state.step===5?'<button class="primary" id="saveBtn">Create campaign →</button>':'<button class="primary" id="doneBtn">Done</button>'}</div></div>`;
 bindWizard();
}
function capture(){
 if(state.step===2){state.name=document.getElementById('wName').value.trim();state.location=document.getElementById('wLoc').value.trim()||'Pune';state.radius=Number(document.getElementById('wRadius').value)||25;state.age=document.getElementById('wAge').value;state.interests=document.getElementById('wInterests').value.split(',').map(x=>x.trim()).filter(Boolean);state.budget=Math.max(1,Number(document.getElementById('wBudget').value)||500)}
 if(state.step===3){state.creative.headline=document.getElementById('wHeadline').value.trim();state.creative.body=document.getElementById('wBody').value.trim();state.creative.cta=document.getElementById('wCta').value;state.creative.hashtags=document.getElementById('wHashtags').value.split(/\s+/).map(x=>x.trim()).filter(x=>x.startsWith('#'));state.creative.keywords=document.getElementById('wKeywords').value.split(',').map(x=>x.trim()).filter(Boolean)}
}
function aiBoostDraft(){
 const h=state.creative.headline||'Your next experience starts here';
 const b=state.creative.body||'Discover a better local experience with PICNIKO.';
 const place=state.location||'Pune';
 const ints=(state.interests||[]).slice(0,5);
 const topic=ints.join(' • ')||'Travel';
 const variants=[
  {headline:`${place} plans made easy — discover more with PICNIKO`,body:`${b} Explore ${topic.toLowerCase()} experiences, offers and places around you. Plan it, share it and go.`,cta:state.creative.cta||'Learn more'},
  {headline:`Looking for a ${place} getaway? Start with PICNIKO`,body:`Find places, food, offers and experiences near ${place}. Build your plan and share it with your people.`,cta:'Plan now'},
  {headline:`Turn your next ${topic.split(' • ')[0].toLowerCase()} idea into a plan`,body:`PICNIKO helps you discover, connect and plan — all in one place.`,cta:'Explore now'}
 ];
 const pick=variants[0];
 state.creative.headline=pick.headline;state.creative.body=pick.body;state.creative.cta=pick.cta;
 const base=[place,...ints,'PICNIKO','near me','weekend getaway','local experiences','travel places'];
 state.creative.keywords=[...new Set(base.map(x=>String(x).trim()).filter(Boolean))];
 state.creative.hashtags=[...new Set(['#PICNIKO',`#${place.replace(/\\s+/g,'')}`,...ints.map(x=>'#'+x.replace(/\\s+/g,'')), '#Travel','#Explore'].filter(x=>x.length>1))].slice(0,10);
 const googleKeywords=[...new Set([...base,'best '+place+' weekend trip','things to do in '+place,'picnic near '+place,'travel places near me'])].slice(0,18);
 const metaInterests=[...new Set([...ints,'Travel','Food','Photography','Weekend getaways'])].slice(0,12);
 const negativeKeywords=['free','jobs','login','complaint'];
 state.creative.aiBoost={mode:'smart-draft',generatedAt:new Date().toISOString(),variants,googleKeywords,metaInterests,picnikoTags:state.creative.hashtags,negativeKeywords};
 render();
 setTimeout(()=>{const r=document.getElementById('aiBoostResult');if(r)r.innerHTML='<b>PIKO AI Boost ready</b><span>Generated 3 copy directions + Google keyword cluster + Meta interest ideas. Review and edit before publishing.</span>'},0);
}
function handleMedia(file){
 if(!file)return;
 const ok=/^(image\/(jpeg|png|webp|gif)|video\/(mp4|quicktime|webm))$/.test(file.type);
 if(!ok){toast('Please select an image or supported video.');return}
 if(file.size>25*1024*1024){toast('Creative must be 25 MB or smaller.');return}
 if(state.creative.media?.previewUrl) URL.revokeObjectURL(state.creative.media.previewUrl);
 state.creative.media={file,name:file.name,type:file.type,size:file.size,previewUrl:URL.createObjectURL(file)};
 render();
}

function bindWizard(){
 document.getElementById('wMedia')?.addEventListener('change',e=>handleMedia(e.target.files?.[0]));
 document.getElementById('aiBoostBtn')?.addEventListener('click',()=>{capture();aiBoostDraft()});
 document.querySelectorAll('.wiz-goal').forEach(b=>b.onclick=()=>{state.goal=b.dataset.goal;render()});
 document.querySelectorAll('.channel-choice').forEach(b=>b.onclick=()=>{const k=b.dataset.channel;state.channels=state.channels.includes(k)?state.channels.filter(x=>x!==k):[...state.channels,k];if(!state.channels.length)state.channels=['picniko'];render()});
 document.getElementById('backBtn')?.addEventListener('click',()=>{capture();state.step--;render()});
 document.getElementById('nextBtn')?.addEventListener('click',()=>{capture();if(state.step===2&&!state.name)state.name='PICNIKO Campaign';state.step++;render()});
 document.getElementById('saveBtn')?.addEventListener('click',saveCampaign);
 document.getElementById('doneBtn')?.addEventListener('click',closeWizard);
}
async function saveCampaign(){
 capture();
 const status=document.getElementById('saveStatus');
 if(!client){status.innerHTML='<span class="err">Supabase client is not configured in this browser.</span>';return}
 state.saving=true;status.innerHTML='<span class="saving">Saving campaign securely…</span>';
 const {data:{user}}=await client.auth.getUser();
 if(!user){status.innerHTML='<span class="err">Please sign in to create a campaign.</span>';state.saving=false;return}
 let uploadedMedia=null;
 if(state.creative.media?.file){
   const f=state.creative.media.file; const safe=f.name.replace(/[^a-zA-Z0-9._-]/g,'_'); const path=`${user.id}/${crypto.randomUUID()}-${safe}`;
   const up=await client.storage.from('ad-creatives').upload(path,f,{contentType:f.type,upsert:false});
   if(up.error){status.innerHTML='<span class="err">Creative upload failed: '+esc(up.error.message)+'</span>';state.saving=false;return}
   uploadedMedia={path,name:f.name,type:f.type,size:f.size};
 }
 const creativeForDb={...state.creative,media:uploadedMedia}; delete creativeForDb.media?.file; delete creativeForDb.media?.previewUrl;
 const payload={owner_user_id:user.id,created_by:user.id,campaign_name:state.name||'PICNIKO Campaign',campaign_type:state.goal,status:'review',daily_budget:Number(state.budget)||0,budget:Number(state.budget)||0,currency:'INR',audience:{location:state.location,radius_km:Number(state.radius)||0,age:state.age,interests:state.interests},creative:creativeForDb,description:state.creative.body,hashtags:state.creative.hashtags||[],ad_keywords:state.creative.keywords||[],media_path:uploadedMedia?.path||null,media_type:uploadedMedia?.type||null,media_name:uploadedMedia?.name||null,ai_strategy:state.creative.aiBoost||{}};
 const {data,error}=await client.from('ad_campaigns').insert(payload).select('id').single();
 if(error){status.innerHTML='<span class="err">Could not save: '+esc(error.message)+'</span>';state.saving=false;return}
 state.campaignId=data.id;
 const rows=state.channels.map(provider=>({campaign_id:data.id,provider,status:provider==='picniko'?'ready':'draft'}));
 const ch=await client.from('ad_campaign_channels').insert(rows);
 if(ch.error){status.innerHTML='<span class="err">Campaign saved, but channel setup needs attention: '+esc(ch.error.message)+'</span>';state.step=6;render();return}
 state.step=6;render();
}
async function loadCampaigns(){
 if(!client)return;
 const {data,error}=await client.from('ad_campaigns').select('id,campaign_name,campaign_type,status,daily_budget,created_at').order('created_at',{ascending:false}).limit(10);
 if(error||!data)return;
 const panel=[...document.querySelectorAll('.panel')].find(x=>x.textContent.includes('Quick campaign'));
 if(panel&&data.length){const box=document.createElement('div');box.className='campaign-mini-list';box.innerHTML=data.map(c=>`<div><b>${esc(c.campaign_name)}</b><span>${esc(c.status)} • ₹${Number(c.daily_budget||0).toLocaleString('en-IN')}/day</span></div>`).join('');panel.appendChild(box)}
}

// V31.2 live workspace enhancements — additive, no existing messaging/home data touched.
const toastEl=document.getElementById('toast');
function toast(msg){if(!toastEl)return;toastEl.textContent=msg;toastEl.classList.add('show');clearTimeout(window.__picToast);window.__picToast=setTimeout(()=>toastEl.classList.remove('show'),2600)}
async function refreshStudioMetrics(){
  if(!client)return;
  const {data,error}=await client.from('ad_campaigns').select('status,daily_budget,created_at').order('created_at',{ascending:false}).limit(200);
  if(error||!data)return;
  const active=data.filter(x=>['active','review'].includes(x.status)).length;
  const drafts=data.filter(x=>x.status==='draft').length;
  const spend=data.reduce((n,x)=>n+Number(x.daily_budget||0),0);
  document.getElementById('mActive')?.replaceChildren(document.createTextNode(String(active).padStart(2,'0')));
  document.getElementById('mDrafts')?.replaceChildren(document.createTextNode(String(drafts).padStart(2,'0')));
  document.getElementById('mSpend')?.replaceChildren(document.createTextNode('₹'+spend.toLocaleString('en-IN')));
}
async function loadCampaigns(){
  if(!client){toast('Supabase client is not configured.');return}
  const {data,error}=await client.from('ad_campaigns').select('id,campaign_name,campaign_type,status,daily_budget,created_at').order('created_at',{ascending:false}).limit(20);
  if(error){toast(error.message);return}
  const panel=[...document.querySelectorAll('.panel')].find(x=>x.textContent.includes('Quick campaign'));
  if(!panel)return;
  panel.querySelector('.campaign-mini-list')?.remove();
  const box=document.createElement('div');box.className='campaign-mini-list';
  if(!data?.length){box.innerHTML='<div class="empty-state">No campaigns yet. Create your first campaign above.</div>'}
  else box.innerHTML=data.map(c=>`<div><div><b>${esc(c.campaign_name)}</b><div class="channel-status">${esc(c.campaign_type)} • ${esc(c.status)}</div></div><span>₹${Number(c.daily_budget||0).toLocaleString('en-IN')}/day</span></div>`).join('');
  panel.appendChild(box);refreshStudioMetrics();
}
// Replace the original nav binding with view-aware behavior.
document.querySelectorAll('.nav[data-view]').forEach(b=>b.addEventListener('click',async()=>{
  document.querySelectorAll('.nav[data-view]').forEach(x=>x.classList.remove('active'));b.classList.add('active');
  const view=b.dataset.view;
  if(view==='campaigns') await loadCampaigns();
  else if(view==='connections') toast('Connections: PICNIKO is ready. Google/Meta require secure OAuth authorization.');
  else if(view==='audience'){modal.classList.add('show');state.step=2;render()}
  else if(view==='creative'){modal.classList.add('show');state.step=3;render()}
  else if(view==='analytics') toast('Analytics will populate after campaigns receive channel events.');
}));
document.querySelectorAll('.connect').forEach(b=>{b.onclick=()=>{toast('Secure OAuth connection is the next publishing step. No credentials are stored in the browser.')}});
refreshStudioMetrics();


// V31.3 mobile app navigation
const mobileCreate=document.getElementById('mobileCreate');
mobileCreate?.addEventListener('click',()=>{modal.classList.add('show');openWizard()});
document.querySelectorAll('.mnav[data-view]').forEach(b=>b.addEventListener('click',async()=>{
  document.querySelectorAll('.mnav[data-view]').forEach(x=>x.classList.remove('active'));b.classList.add('active');
  const view=b.dataset.view;
  if(view==='campaigns') await loadCampaigns();
  else if(view==='audience'){modal.classList.add('show');state.step=2;render()}
  else if(view==='connections'){toast('Connections: PICNIKO is ready. Google/Meta require secure OAuth authorization.')}
  else {window.scrollTo({top:0,behavior:'smooth'})}
}));
