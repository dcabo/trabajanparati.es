# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_trabajanparati.es_session',
  :secret      => 'fbe17a38833af0a3a5de6c24720a9cd762484ccd3376aa97ce697a007c12d23589b90a2ed2b7ae44f6f3925fd8d4357ae4515b62e3c0d313f8808dcc9435aab2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
