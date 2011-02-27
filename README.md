# Minime
Minime is a simple URL shortener application (like TinyUrl, bit.ly, etc) built using Ruby and Sinatra.

## Getting started

1. git clone git@github.com:brentertz/minime.git
2. cd minime
3. Install gems:  
    `bundle install`
4. Initialize the database:  
    `irb`  
    `require './app'`  
    `DataMapper.auto_migrate!`
5. Start app: `shotgun`
6. Open your browser to: `http://localhost:9393`
