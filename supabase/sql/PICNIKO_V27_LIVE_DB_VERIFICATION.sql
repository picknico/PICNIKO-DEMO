-- PICNIKO V27 LIVE DB VERIFICATION
-- READ ONLY. No CREATE/ALTER/INSERT/UPDATE/DELETE.

select table_name from information_schema.tables where table_schema = 'public' and table_name in ('friend_requests','conversations','conversation_members','messages','profiles') order by table_name;

select proname, pg_get_function_identity_arguments(oid) as arguments, pg_get_function_result(oid) as return_type from pg_proc where pronamespace = 'public'::regnamespace and proname in ('discover_message_users','send_friend_request','respond_friend_request','cancel_friend_request','get_friend_status','get_or_create_direct_conversation') order by proname;

select 'friend_requests' as item, count(*)::bigint as value from public.friend_requests
union all select 'conversations', count(*)::bigint from public.conversations
union all select 'conversation_members', count(*)::bigint from public.conversation_members
union all select 'messages', count(*)::bigint from public.messages;
