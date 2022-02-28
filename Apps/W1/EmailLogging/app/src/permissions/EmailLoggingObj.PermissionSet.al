/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 1680 "Email Logging - Obj."
{
    Assignable = false;
    Access = Internal;

    Permissions = codeunit "Feature Email Log. Using Graph" = X,
                  codeunit "Email Logging Job Runner" = X,
                  codeunit "Email Logging Invoke" = X,
                  codeunit "Email Logging Management" = X,
                  codeunit "Email Logging OAuth Client" = X,
                  codeunit "Email Logging API Client" = X,
                  codeunit "Email Logging API Helper" = X,
                  codeunit "Email Logging Message" = X,
                  page "Email Logging Setup" = X,
                  page "Email Logging Setup Wizard" = X,
                  table "Email Logging Setup" = X;
}