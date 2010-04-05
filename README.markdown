# OmniAuth

I know what you're thinking: yes, it's yet **another** authentication solution for Rack applications. But we're going to do things a little bit differently this time. OmniAuth is built from the ground up on the philosophy that **authentication is not the same as identity**. OmniAuth is based on two observations:

1. The traditional 'sign up using a login and password' model is becoming the exception, not the rule. Modern web applications offer external authentication via OpenID, Facebook, and OAuth.
2. The interconnectable web is no longer a dream, it is a necessity. It is not unreasonable to expect that one application may need to be able to connect to one, three, or twelve other services. Modern authentication systems should a user's identity to be associated with many authentications.

## Theoretical Framework

OmniAuth works on the principle that every authentication system can essentially be boiled down into two "phases".

### The Request Phase

In the Request Phase, we *request* information from the user that is necessary to complete authentication. This information may be **POST**ed to a URL or performed externally through an authentication process such as OpenID.

### The Callback Phase

In the Callback Phase, we receive an authenticated **unique identifier** that can differentiate this user from other users of the same authentication system. Additionally, we may provide **user information** that can be automatically harvested by the application to fill in the details of the authenticating user.