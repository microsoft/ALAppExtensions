report 2510 "Extension Management Launcher"
{
    Caption = 'Extension Management';
    AdditionalSearchTerms = 'app,add-in,customize,plug-in';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = false;

    trigger OnInitReport()
    var
        NavApp: Record "NAV App";
    begin
        if NavApp.WritePermission() then
            Page.Run(Page::"Extension Management")
        else
            if Confirm(NotSufficientPermissionTxt) then
                Hyperlink(HelpLink);
    end;

    var
        HelpLink: Label 'https://go.microsoft.com/fwlink/?linkid=828706', Locked = true;
        NotSufficientPermissionTxt: Label 'You do not have sufficient permissions to manage extensions. Please contact your administrator.\\Do you want to learn more about this issue?';
}