/**
* This is the default settings file provided by Node-RED.
*
* It can contain any valid JavaScript code that will get run when Node-RED
* is started.
*
* Lines that start with // are commented out.
* Each entry should be separated from the entries above and below by a comma ','
*
* For more information about individual settings, refer to the documentation:
*    https://nodered.org/docs/user-guide/runtime/configuration
**/
const userlist = {}

module.exports = {
   uiPort: process.env.PORT || 80,
   httpNodeRoot: process.env.HTTPROOT || "/",
   httpAdminRoot: process.env.HTTPROOT || "/",
   adminAuth: {
        type:"strategy",
        strategy: {
            name: "keycloak",
            label: 'Sign in',
            icon:"fa-lock",
            strategy: require("passport-keycloak-oauth2-oidc").Strategy,
            options: {
                clientID: "nodered",
                realm: 'nodered',
                publicClient: "false",
                clientSecret: process.env.KEYCLOAK_NODERED_CLIENT_SECRET,
                sslRequired: "external",
                authServerURL: "https://keycloak."+process.env.DOMAINNAME+"/auth",
                callbackURL: process.env.ACCESSURL+"/auth/strategy/callback",
                verify: function(token, tokenSecret, profile, done) {
                    //console.log('profile:\n', profile);
                    if (process.env.KEYCLOAK_WRITER_ROLE == '*'){
                        userlist[profile.username] = '*'
                    } else if ('resource_access' in profile._json
                       && profile._json.resource_access.nodered.roles.includes(process.env.KEYCLOAK_WRITER_ROLE)){
                        userlist[profile.username] = process.env.KEYCLOAK_WRITER_ROLE
                    } else {
                        userlist[profile.username] = 'read-only'
                    }
                    // console.log('profile.username:\n', profile.username);
                    done(null, profile);
                }
            },
        },
        users: function(username) {
            return new Promise(function(resolve) {
                // console.log('username from users(): \n', username)
                // console.log('userlist from users(): \n', userlist)
                if (username in userlist){
                    if (userlist[username] == process.env.KEYCLOAK_WRITER_ROLE){
                        var user = { username: username, permissions: "*" };
                    } else {
                        var user = { username: username, permissions: "read" };
                    }
                } else {
                    var user = null;
                }
                // console.log('user after validation from users(): \n', user)
                resolve(user);
            });
        }
    },
   mqttReconnectTime: 15000,
   serialReconnectTime: 15000,
   debugMaxLength: 1000,
   functionGlobalContext: {
   },
   exportGlobalContextKeys: false,
   editorTheme: {
       projects: {
           enabled: process.env.NODE_RED_ENABLE_PROJECTS || true
       }
   },
   logging: {
    console: {
        level: "debug",
        metrics: false,
        audit: false
    }
   }
}
