/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 1690 "Bank Deposits - Objects"
{
    Assignable = false;
    Access = Public;

    Permissions = codeunit "Bank Deposit-Post" = X,
                  codeunit "Bank Deposit-Post + Print" = X,
                  codeunit "Bank Deposit-Post (Yes/No)" = X,
                  codeunit "Bank Deposit-Printed" = X,
                  codeunit "Bank Deposit Subscribers" = X,
                  codeunit "Entry Application Mgt" = X,
                  codeunit "Posted Bank Deposit-Delete" = X,
                  codeunit "Setup Bank Deposit Reports" = X,
                  page "Bank Acc. Comment List" = X,
                  page "Bank Acc. Comment Sheet" = X,
                  page "Bank Deposit" = X,
                  page "Bank Deposit List" = X,
                  page "Bank Deposits" = X,
                  page "Bank Deposit Subform" = X,
                  page "Posted Bank Deposit" = X,
                  page "Posted Bank Deposit Lines" = X,
                  page "Posted Bank Deposit List" = X,
                  page "Posted Bank Deposit Subform" = X,
                  report "Bank Deposit" = X,
                  report "Bank Deposit Test Report" = X,
                  table "Bank Acc. Comment Line" = X,
                  table "Bank Deposit Header" = X,
                  table "Posted Bank Deposit Header" = X,
                  table "Posted Bank Deposit Line" = X;
}