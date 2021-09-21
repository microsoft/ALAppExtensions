# Dmitry Katson: Email - Guest Outlook REST API

## Release Notes

Notes for the released versions

### 18.1.0.0
*17/09/21*

In order to send email from the Business Central, the user should have Outlook Account in the same tenant as the Business Central. However in situations, when the user is not in the same tenant (Guest User), this is not possible. The solution is to use the OAuth2.0 client credential flow (application permissions). Application permissions allow us to authenticate to Azure AD using the guest user permissions. 

Assume you have next architecture:

<img src="https://user-images.githubusercontent.com/29101017/133727251-ecb09ae5-0f5a-4858-add0-027ec4a8aa40.png" width="640">

#### Register an Application
First step is to create a new application in Azure AD **Tenant B**.

- Login to Azure as **Tenant B** administrator
- Go to **Azure Active Directory** -> **App Registrations** -> **New Registration**
- Set Name
- Select *Accounts in any organizations (multitenant)*
- Set Redirect Url to "https://businesscentral.dynamics.com/OAuthLanding.htm"

<img src="https://user-images.githubusercontent.com/29101017/133728127-67e6f985-8f0e-47e8-9f2a-802fea12018e.png" width="640">

#### Set Application Permissions
Next step is to set the permissions for the application.

- Created Application -> **API Permissions** -> **Add Permission** -> **Microsoft Graph**
- Choose **Delegated Permissions**

<img src="https://user-images.githubusercontent.com/29101017/133728776-dcebb752-825f-4d0b-954c-1a8e422e334e.png" width="640">

- Find Mail and choose *Mail.Send* and *Mail.Send.Shared*

<img src="https://user-images.githubusercontent.com/29101017/133729118-bc7d3284-205f-4b80-b27b-9fb31a3e58ce.png" width="640">

#### Create Client Secrets
Next step is to create client secrets for the application.

- Created Application -> **Certificates and Secrets** -> **New Client Secret**

<img src="https://user-images.githubusercontent.com/29101017/133729829-6a10ec58-f020-4ee7-b72c-f869434479e0.png" width="640">

- Set the Name and Expriation Period. You will have to create new secret, when the expiration period is reached.
- Click **Add**

Important: Save the *Value* **now**. You will not be able to see the value again.

<img src="https://user-images.githubusercontent.com/29101017/133730195-9e6d143b-af06-4e4d-b613-54f9c10df6ec.png" width="640">

- Created Application -> **Overview**. Save the *Application (client) Id*. You will need it later.

<img src="https://user-images.githubusercontent.com/29101017/133730530-e13f6842-7649-445a-9ea5-b8a6250163d8.png" width="640">

#### Business Central. Check User Permissions
Next step is to check the permissions for the user for the user, who will setup the Azure AD application.
- Login to Business Central as **Administrator**
- Go to **Users**
- Add *EMAIL SETUP* and *D365 SECURITY* permissions to the user

#### Business Central. Configure Azure App Registration
Next step is to configure the Azure App Registration in Business Central.

- Login to Business Central as **Administrator**
- Go to **Assisted Setup**. Find *Set up a connection to guest outlook*

<img src="https://user-images.githubusercontent.com/29101017/133730793-27046096-b9af-4e0d-a838-883dd7c06762.png" width="640">

- Set the *Application (client) Id* to the *Client Id*
- Set the *Client Secret Value* to the *Client Secret*
- Check *Grant Consent*

<img src="https://user-images.githubusercontent.com/29101017/133731106-072899a4-6614-4957-a115-cb431fcfb20a.png" width="640">

- You will be asked to log in to the *Tenant B* to grant consent. Log in as a *Tenant B* administrator

<img src="https://user-images.githubusercontent.com/29101017/133731512-e7133189-efdf-4062-a48d-f0a14f68cc7a.png" width="640">

- Click **Accept**

- Verify the Registration

- You will be asked to log in to the *Tenant B* to check the connection. Log in as a *Tenant B* administrator. You should see the Success message.

<img src="https://user-images.githubusercontent.com/29101017/133731930-871fba49-1131-40f1-b84f-9b4af5f9981f.png" width="640">

- Click **OK**

<img src="https://user-images.githubusercontent.com/29101017/133732063-ec4ce60a-f63c-4544-a32a-48bd1f59f7a0.png" width="640">


    
    






