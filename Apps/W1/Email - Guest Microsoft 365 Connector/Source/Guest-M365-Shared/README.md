# Dmitry Katson: Email - Guest Microsoft 365 Connector

## Release Notes

Notes for the released versions

### 18.1.0.0
*16/09/21*

*Initial release*

#### Prerequisites
In order to use this connector you need to have the following apps installed and configured: *Email - Guest Outlook REST API*
The shared email account must be configured in the guest Tenant. The guest user must be granted *Send On Behalf Of* permission to the shared email account.
#### Send email from a Guest Shared Account in Business Central
First, you need to create a Email Account

- Log in to the Business Central as a guest user
- Go to the **Email Accounts**
- Click **New** -> **Add an Email Account**
- Choose **Guest Microsoft 365** -> **Next**

<img width="595" alt="image" src="https://user-images.githubusercontent.com/29101017/133738206-62c5194e-5517-444a-8561-288ba190bcb3.png">

- Fill the Email Name and Email Address of the shared email account

<img width="591" alt="image" src="https://user-images.githubusercontent.com/29101017/133738452-0eb9f424-1f96-4ba2-9cfc-81066ed9dc8b.png">

- Click **Next**

- Click **Send Test Email**. You should see a message saying that the email was sent successfully.

<img width="522" alt="image" src="https://user-images.githubusercontent.com/29101017/133739154-289f56c6-224a-4d19-9889-36232426cc9d.png">

- Click **Finish**

<img width="900" alt="image" src="https://user-images.githubusercontent.com/29101017/133739343-5cee2624-9ed2-413c-bc79-f5825b871c9d.png">

Now you can use the connector to send emails from a guest shared email account.