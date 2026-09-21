import { getDb } from './db.js';

export async function discoverPeople(search='', limit=30){
  const db=await getDb();
  if(!db) return {data:[],error:new Error('Supabase not configured')};
  return db.rpc('picniko_discover_people',{p_search:search,p_limit:limit});
}
export async function sendFriendRequest(userId){
  const db=await getDb(); if(!db) return {error:new Error('Supabase not configured')};
  return db.rpc('picniko_send_friend_request',{p_target:userId});
}
export async function respondFriendRequest(connectionId,action){
  const db=await getDb(); if(!db) return {error:new Error('Supabase not configured')};
  return db.rpc('picniko_respond_friend_request',{p_connection:connectionId,p_action:action});
}
export async function rankedFeed(limit=20){
  const db=await getDb(); if(!db) return {data:[],error:new Error('Supabase not configured')};
  return db.rpc('picniko_ranked_feed',{p_limit:limit});
}
export async function trackContent(contentId,eventType,watchSeconds=null){
  const db=await getDb(); if(!db) return {error:new Error('Supabase not configured')};
  const {data:{user}}=await db.auth.getUser();
  if(!user) return {error:new Error('LOGIN_REQUIRED')};
  return db.from('picniko_content_events').insert({content_id:contentId,user_id:user.id,event_type:eventType,watch_seconds:watchSeconds});
}
