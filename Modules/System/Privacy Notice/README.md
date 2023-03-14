This module provides a simple way handle privacy notices.
The module will both show privacy, store the approval state and give admins a simple way to agree/disagree with all privacy notices.

This module can be used to:
- Create a privacy notice
- Set up a default privacy notice
- Show/Confirm a privacy notice is agreed to
- Get/Change the approval state of privacy notices
- Override the default privacy notice approval page

### How to create a privacy notice
```
procedure CreatePrivacyNotice()
var
    PrivacyNotice: Codeunit "Privacy Notice";
begin
    PrivacyNotice.CreatePrivacyNotice('Microsoft Teams', 'Microsoft Teams');
end;
```

### How to create a default privacy notice (triggered from CreateDefaultPrivacyNotices)
```
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Privacy Notice", 'OnRegisterPrivacyNotices', '', false, false)]
local procedure CreatePrivacyNoticeRegistrations(var TempPrivacyNotice: Record "Privacy Notice" temporary)
begin
    TempPrivacyNotice.ID := 'Microsoft Teams';
    TempPrivacyNotice."Integration Service Name" := 'Microsoft Teams';
    if not TempPrivacyNotice.Insert() then;
end;
```

### How to a privacy notice is agreed to before calling external service
```
procedure CallTeamsService()
var
    PrivacyNotice: Codeunit "Privacy Notice";
begin
    if not PrivacyNotice.ConfirmPrivacyNoticeApproval('Microsoft Teams') then
        exit;

    ExternalServiceCallToTeams();
end;
```

### How to get the approval state of a privacy notice without asking user to agree
```
procedure CallTeamsService()
var
    PrivacyNotice: Codeunit "Privacy Notice";
begin
    if PrivacyNotice.GetPrivacyNoticeApprovalState('Microsoft Teams') <> "Privacy Notice Approval State"::Agreed then
        exit;

    ExternalServiceCallToTeams();
end;
```

### How to set the approval state of a privacy notice
```
procedure ApproveTeamsIntegration()
var
    PrivacyNotice: Codeunit "Privacy Notice";
begin
    PrivacyNotice.SetApprovalState('Microsoft Teams', "Privacy Notice Approval State"::Agreed);
end;
```

### How to override the default privacy notice approval page
```
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Privacy Notice", 'OnBeforeShowPrivacyNotice', '', false, false)]
local procedure OverrideTeamsPrivacyNotice(PrivacyNotice: Record "Privacy Notice"; var Handled: Boolean)
begin
    if Handled then
        exit;
    if PrivacyNotice.ID <> 'MICROSOFT TEAMS' then
        exit;

    ShowOwnPrivacyNoticeAndSetApprovalState(PrivacyNotice);
    Handled := true;
end;
```


### How to override Edit in Excel functionality
```
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Edit in Excel", 'OnEditInExcel', '', false, false)]
local procedure OnEditInExcel(ServiceName: Text[240]; ODataFilter: Text; SearchFilter: Text; var Handled: Boolean)
begin
    if HandleOnEditInExcel(ServiceName, ODataFilter, SearchFilter) then
        Handled := True;
end;
```

