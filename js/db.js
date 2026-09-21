import {createClient, isConfigured} from './supabase.js';

let client = null;
export function getDb(){
  if(!client && isConfigured()) client = createClient();
  return client;
}
export function dbReady(){ return !!getDb(); }
export async function currentUser(){
  const db=getDb();
  if(!db) return null;
  const {data}=await db.auth.getUser();
  return data?.user ?? null;
}
