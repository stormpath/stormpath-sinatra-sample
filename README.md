# Stormpath Sinatra Sample

This is a basic web application that will show you how to create, load, edit, and delete accounts using the Stormpath Ruby SDK and Sinatra.

![Stormpath Sinatra Sample Homepage](https://raw.githubusercontent.com/DamirSvrtan/stormpath-sinatra-sample/master/ScreenshotHomepage.png)

## Installation

These installation steps assume you've already installed RubyGems. If you've not yet installed RubyGems, go [here](http://docs.rubygems.org/read/chapter/3).

You'll need the Bundler gem in order to install dependencies listed in your project's Gemfile. To install Bundler:

```
$ gem install bundler
```

Then, install dependencies using Bundler:

```
$ bundle install
```

## Quickstart Guide

1.  If you have not already done so, register as a developer on [Stormpath](http://stormpath.com/) and set up your API credentials and resources:

    1.  Create a [Stormpath](http://www.stormpath.com) developer account and [create your API Keys](http://www.stormpath.com/docs/ruby/product-guide#AssignAPIkeys) downloading the <code>apiKey.properties</code> file into a <code>.stormpath</code> folder under your local home directory.

    2.  Through the [Stormpath Admin UI](http://api.stormpath.com/login), create yourself an [Application Resource](http://www.stormpath.com/docs/stormpath-basics#keyConcepts). Ensure that this is a new application and not the default administrator one that is created when you create your Stormpath account.
        
        On the Create New Application screen, make sure the "Create a new directory with this application" box is checked. This will provision a [Directory Resource](http://www.stormpath.com/docs/stormpath-basics#keyConcepts) along with your new Application Resource and link the Directory to the Application as an [Account Store](http://www.stormpath.com/docs/stormpath-basics#keyConcepts). This will allow users associated with that Directory Resource to authenticate and have access to that Application Resource.

        It is important to note that although your developer account (step 1) comes with a built-in Application Resource (called "Stormpath") - you will still need to provision a separate Application Resource.

    3.  Take note of the _REST URL_ of the Application you just created. Your web application will communicate with the Stormpath API in the context of this one Application Resource (operations such as: user-creation, authentication, etc.)

2.  Set ENV variables as follows (perhaps in ~/.bashrc):

    ```
    export STORMPATH_API_KEY_FILE_LOCATION=xxx
    export STORMPATH_APPLICATION_URL=aaa
    ```

    There are other ways to pass API information to the SDK client; see the
    [Stormpath SDK documentation](https://stormpath.com/docs/ruby/product-guide) for more info.

3.  Run the application with Rack (installed by Bundler):

    ```
    $ rackup
    ```

    You should see output resembling the following:

    ```
    [2013-05-03 11:38:19] INFO  WEBrick 1.3.1
    [2013-05-03 11:38:19] INFO  ruby 2.0.0 (2013-02-24) [x86_64-darwin12.2.1]
    [2013-05-03 11:38:19] INFO  WEBrick::HTTPServer#start: pid=9304 port=9292
    ```

4.  Visit the now-running site in your browser at http://0.0.0.0:9292

Note: By design, you will need to first create a user with the application before being able to authenticate that user.

## Common Use Cases

### User Creation

This tutorial assumes you've not yet created any accounts in the Stormpath directory mentioned in the Quickstart Guide.

To create your first account:

1.  Fire up the demo application, as explained in the Quickstart Guide

2.  Open http://localhost:9292 in your web browser

3.  Click the "Register" button

4.  Complete the form and click the "Save" button

Congratulations! Your first account has been created. Assuming all has gone well, you should be able to log in to the sample application using its email and password.

If you're interested in the log in/out implementation, check out routes/session.rb. In that file you'll find a route whose handler shows the login view (GET "/session/new") and a route whose handler forwards your username and password off to Stormpath for authentication (POST "/session").

### Listing Accounts

After creating an account ("User Creation") and logging in, you will be presented with a list of all the accounts created to-date. These accounts have been obtained from the Stormpath application and stored as settings of your Sinatra app, like so:

```ruby
class SampleApp < Sinatra::Base
  ...
  set :client, Stormpath::Client.new({ api_key_file_location: ENV['STORMPATH_API_KEY_FILE_LOCATION'] })
  set :application, settings.client.applications.get(ENV['STORMPATH_APPLICATION_URL'])
  ...
end
```

### Accessing the Stormpath Client and Application

When the Sinatra sample application starts up, a request is made to the Stormpath API in order to load your application. The resulting Stormpath Resource objects are accessible through the "settings" hash on your Sinatra application, like so:

```ruby
# in routes/accounts.rb

module Sinatra
  module SampleApp
    module Routing
      module Accounts
        def self.registered(app)
          app.get '/sample_route' do
            ...
            settings.client # an instance of a Stormpath Client
            settings.application # an instance of the Stormpath Application
            ...
          end
        end
      end
    end
  end
end
```

## Testing Specific Configurations

### Post-Create Account Validation

It is possible to configure a Stormpath directory in such a way that when accounts are provisioned to it that they must be verified (by clicking a link) via email before logging in. The verification link in the email will by default point to the Stormpath server - but can be configured to point to your local server. This is useful if you wish to prevent the account from having to go to the Stormpath site after registration.

To enable post-creation verififation for a directory:

1.  Head to the [Stormpath Admin UI](http://api.stormpath.com/login), log in, and click
    "Directories."

2.  From there, click the directory whose REST URL you have used to configure
    your application (see Quickstart Guide):

3.  Click "Workflows" and then "Show" link next to "Account Registration and
    Verification".

4.  Click the box next to "Enable Registration and Verification
    Workflow."

5.  Finally, click the box next to "Require newly registered accounts to verify
    their email address."

After creating an account, an email will be sent to the email address specified during creation. This email contains a verification link which must be clicked before the account can authenticate successfully.

If you wish for that email link to point to your local server - which will then use the Stormpath SDK to verify the account - modify "Account Verification Base URL" to "http://0.0.0.0:9292/account_verifications".

### Local Password Reset Token Validation

It is possible to configure a Stormpath directory in such a way that when accounts reset their password that the email they receive points to a token-verification URL on your local server. If you wish to configure the directory to point to your local server (instead of the Stormpath server):

1.  Head to the [Stormpath Admin UI](http://api.stormpath.com/login), log in, and click
    "Directories."

2.  From there, click the directory whose REST URL you have used to configure
    your application (see Quickstart Guide):

3.  Click "Workflows" and then "Show" link next to "Password Reset"

4.  Change the value of "Base URL" to
    "http://0.0.0.0:9292/password_reset_tokens"

Now the email a account receives after resetting their password will contain a link pointing to a password reset token-verification URL on your system.

### Group Membership

In order to demonstrate the Stormpath Group functionality, the demo application conditionally shows / hides a "delete" link next to each account on the accounts-listing page based on the logged-in account's membership in a group named "admin".

If you wish to experiment with group membership:

1.  Head to the [Stormpath Admin UI](http://api.stormpath.com/login), log in, and click
    "Directories."

2.  From there, click the directory whose REST URL you have used to configure
    your application (see Quickstart Guide):

3.  Click "Groups" and then "Create Group"

4.  Name the group "admin"

5.  From the group-list screen, click the name of the "admin" group

6.  Click the "Accounts" tab and then "Assign Accounts"

7.  Select an account and then click "Assign Account"

This account has now been associated with the "admin" group. Upon logging in to the sample application with this account, you will see a new "Delete" button appear next to each row in the list of accounts.

## Registering via Facebook or Google

Stormpath supports accessing accounts from a number of different locations including Google and Facebook. Both Google and Facebook use OAuth 2.0 protocol for authentication / authorization and Stormpath can leverage their authorization code (or access tokens) to return an Account for a given code.

To use Facebook or Google login within this application, you need to create a Facebook application and(or) a Google application and appropriate directories on Stormpath.

### Creating a Facebook application:

1. Go to https://developers.facebook.com/, click on the Apps tab and select "Create a New App".
2. Fill in the name of the application, and afterwards head on to the Settings menu on the left.
3. In the settings menu enter the Contact Email information.
4. In the settings menu click the 'Add platform' button, and select 'Website'. Under the Site URL enter http://localhost:9292/ and save changes.
5. Go to the "Status & Review" tab on the left, and select 'Yes' for the question: "Do you want to make this app and all its live features available to the general public?" 
6. Head on back to the Dashboard, and copy the App ID and App Secret.
7. Open the application code and either paste the ID and Secret to the 'stormpath-sample-app.rb' or set them as appropriate environment variables.

### Creating a Google application:

1. Go to https://console.developers.google.com/project and click the 'CREATE PROJECT' button.
2. Go to your project settings and click on 'APIs & auth', and afterwards 'APIs'. Enable 'Contacts API' and 'Google+ API'.
3. In the left menu select 'Credentials' and click on 'CREATE NEW CLIENT ID'. Select 'Web Application' and fill in the AUTHORIZED JAVASCRIPT ORIGINS with http://localhost:9292 and AUTHORIZED REDIRECT URI with http://localhost:9292/auth/google_oauth2/callback
4. Copy the Client ID and Client Secret.
5. Open the application code and either paste the ID and Secret to the 'stormpath-sample-app.rb' or set them as appropriate environment variables.

### Creating Facebook and Google Directories on Stormpath

Once you get access tokens, the application will send them to Stormpath to fill in the basic info for the user.
To be able to do that, you will need to head on to the [Stormpath Admin Console](https://api.stormpath.com) and create a Facebook and(or) a Google Directory:

1. After logging in, select the Directories tab and create a new directory.
2. Select either a Facebook or a Google Directory and enter the ID and Secret (for Google enter the Redirect URI).
3. You'll need to add them as Account Stores for your application, so head on to the Applications tab, find your application and select it.
4. Select the Account Stores tab, click on the 'Add Account Store' button and find your newly created Facebook/Google directory.
5. That's it, fire up the application with 'rackup' and login via OAuth2.
