/// This is the exact public Supabase project used by MediaFlow v372.
/// The publishable key is specifically designed to be embedded in clients.
/// NEVER embed the Supabase service-role key in a mobile/desktop application.
abstract final class MediaFlowConfig {
  static const supabaseUrl = String.fromEnvironment(
    'MEDIAFLOW_SUPABASE_URL',
    defaultValue: 'https://wgeijxfdpgehesxialxm.supabase.co',
  );
  static const supabasePublishableKey = String.fromEnvironment(
    'MEDIAFLOW_SUPABASE_KEY',
    defaultValue: 'sb_publishable_d2P0qZlvGZOSqcUzEg3BNg_3wQsHY_M',
  );
}
