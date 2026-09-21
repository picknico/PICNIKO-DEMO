import { getDb } from './db.js';

export async function likePost(postId){
  const db=getDb(); if(!db) return {error:new Error('Supabase not configured')};
  const {data:{user}}=await db.auth.getUser(); if(!user) return {error:new Error('LOGIN_REQUIRED')};
  // Existing production content-event table is preserved; this records the interaction without inventing a second post system.
  return db.from('picniko_content_events').insert({content_id:postId,user_id:user.id,event_type:'like'});
}
export async function followUser(userId){
  const db=getDb(); if(!db) return {error:new Error('Supabase not configured')};
  const {data:{user}}=await db.auth.getUser(); if(!user) return {error:new Error('LOGIN_REQUIRED')};
  return db.from('social_follows').upsert({follower_id:user.id,following_id:userId},{onConflict:'follower_id,following_id'});
}
