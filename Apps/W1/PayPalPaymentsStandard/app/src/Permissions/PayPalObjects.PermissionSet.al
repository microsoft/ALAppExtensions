permissionset 45616 "PayPal - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'PayPal Payments Standard - Objects';

    Permissions = codeunit "MS - PayPal Create Demo Data" = X,
                    codeunit "MS - PayPal Standard Mgt." = X,
                    codeunit "MS - PayPal Transactions Mgt." = X,
                    codeunit "MS - PayPal Webhook Management" = X,
                    page "MS - PayPal Standard Accounts" = X,
                    page "MS - PayPal Standard Settings" = X,
                    page "MS - PayPal Standard Setup" = X,
                    page "MS - PayPal Standard Template" = X,
                    table "MS - PayPal Standard Account" = X,
                    table "MS - PayPal Standard Template" = X,
                    table "MS - PayPal Transaction" = X;
}
