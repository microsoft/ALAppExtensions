# Introduction
This module contains the client control add-in and specific methods for authorizing a resource. 

Use this module to do the following:
•	Trigger authorization.
•	Determine whether the client control add-in is installed and ready.
•	Receive the authorization code during the authorization process.
•	Receive information about why the authorization process failed.

## Usage example
The following example shows how to integrate this module in an extension.

    var
        AuthRequestUrl: Text;

    usercontrol(OAuthIntegration; OAuthControlAddIn)
    {
        ApplicationArea = Basic, Suite;

        // this event is triggered when an authorization code has been retrieved successfully
        trigger AuthorizationCodeRetrieved(AuthCode: Text)
            begin

            end;

        // this event is triggered when there was a failure in obtaining an authorization code
        trigger AuthorizationErrorOccurred(AuthError: Text; AuthErrorDescription: Text)
            begin

            end;

        // this event is triggered when the client control add-in has been loaded and is ready to use
        trigger ControlAddInReady();
            begin
                CurrPage.OAuthIntegration.StartAuthorization(AuthRequestUrl);
            end;
    }
# Public Objects
