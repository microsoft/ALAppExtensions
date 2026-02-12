namespace Microsoft.Foundation.Address.IdealPostcodes;

using Microsoft.Foundation.Address;
using System.Environment.Configuration;

codeunit 9401 "IPC Address Lookup Helper"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Post Code" = ri;

    var
        AwarenessNotificationNameTxt: Label 'Notify the user of address provider capabilities.';
        AwarenessNotificationDescriptionTxt: Label 'Turns the user''s attention to the address provider capabilities.';
        UserDisabledNotificationTxt: Label 'The user disabled notification %1.', Locked = true;
        AwarenessNotificationTxt: Label 'You can use an address provider to retrieve and validate addresses based on postcodes.';
        SetUpNotificationActionTxt: Label 'Set it up here.';
        DisableNotificationTxt: Label 'Disable this notification.';

    procedure LookupAndUpdateAddress(var RecRef: RecordRef; AddressFieldNo: Integer; Address2FieldNo: Integer; CityFieldNo: Integer; PostCodeFieldNo: Integer; CountyFieldNo: Integer; CountryCodeFieldNo: Integer)
    var
        IPCManagement: Codeunit "IPC Management";
        Address: Text[100];
        Address2: Text[50];
        City: Text[30];
        PostCode: Code[20];
        County: Text[30];
        CountryCode: Code[10];
    begin
        // Get current values
        Address := CopyStr(GetFieldValue(RecRef, AddressFieldNo), 1, MaxStrLen(Address));
        Address2 := CopyStr(GetFieldValue(RecRef, Address2FieldNo), 1, MaxStrLen(Address2));
        City := CopyStr(GetFieldValue(RecRef, CityFieldNo), 1, MaxStrLen(City));
        PostCode := CopyStr(GetFieldValue(RecRef, PostCodeFieldNo), 1, MaxStrLen(PostCode));
        County := CopyStr(GetFieldValue(RecRef, CountyFieldNo), 1, MaxStrLen(County));
        CountryCode := CopyStr(GetFieldValue(RecRef, CountryCodeFieldNo), 1, MaxStrLen(CountryCode));

        // Perform lookup
        IPCManagement.LookupAddress(Address, Address2, City, PostCode, County, CountryCode);

        // Update record
        SetFieldValue(RecRef, AddressFieldNo, Address);
        SetFieldValue(RecRef, Address2FieldNo, Address2);
        SetFieldValue(RecRef, CityFieldNo, City);
        SetFieldValue(RecRef, PostCodeFieldNo, PostCode);
        SetFieldValue(RecRef, CountyFieldNo, County);
        SetFieldValue(RecRef, CountryCodeFieldNo, CountryCode);

        CreateNewPostcodeIfNotExists(City, PostCode, County, CountryCode);
    end;

    local procedure CreateNewPostcodeIfNotExists(City: Text[30]; PostCodeValue: Code[20]; County: Text[30]; CountryRegionCode: Code[10])
    var
        PostCode: Record "Post Code";
    begin
        if (City = '') or (PostCodeValue = '') then
            exit;

        // Entered postcode already exists
        PostCode.SetRange(Code, PostCodeValue);
        PostCode.SetRange(City, City);
        if not PostCode.IsEmpty() then
            exit;

        // Otherwise create one
        PostCode.Init();
        PostCode.Code := PostCodeValue;
        PostCode.City := City;
        PostCode."Search City" := UpperCase(City);
        PostCode."Country/Region Code" := CountryRegionCode;
        PostCode.County := County;
        PostCode.Insert();
    end;

    procedure SupportedCountryOrRegionCode(CountryOrRegionCode: Code[10]): Boolean
    begin
        exit(CountryOrRegionCode in ['GB', 'UK', 'IE', 'NL', 'SG', '']);
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState();
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(GetAwarenessNotificationId(), AwarenessNotificationNameTxt, AwarenessNotificationDescriptionTxt, true);
    end;

    procedure NotifyUserAboutAddressProviderCapabilities()
    var
        MyNotifications: Record "My Notifications";
        IPCProvider: Codeunit "IPC Provider";
        PostCodeServiceManager: Codeunit "Postcode Service Manager";
        AwarenessNotification: Notification;
        IsConfigured: Boolean;
    begin
        if not MyNotifications.IsEnabled(GetAwarenessNotificationId()) then
            exit;

        PostCodeServiceManager.IsServiceConfigured(IPCProvider.GetServiceKey(), IsConfigured);
        if IsConfigured then
            exit;

        AwarenessNotification.Id(GetAwarenessNotificationId());
        AwarenessNotification.SetData('NotificationId', GetAwarenessNotificationId());
        AwarenessNotification.Message(AwarenessNotificationTxt);
        AwarenessNotification.AddAction(SetUpNotificationActionTxt, Codeunit::"IPC Address Lookup Helper", 'NotificationOnConfigure');
        AwarenessNotification.AddAction(DisableNotificationTxt, Codeunit::"IPC Address Lookup Helper", 'DisableNotificationForUser');
        AwarenessNotification.Send();
    end;

    procedure GetAwarenessNotificationId(): Guid;
    begin
        exit('a5480dd3-24d2-4540-9492-3cba865956d0');
    end;

    procedure DisableNotificationForUser(HostNotification: Notification)
    var
        MyNotifications: Record "My Notifications";
        NotificationId: Text;
    begin
        NotificationId := HostNotification.GetData('NotificationId');
        if MyNotifications.Get(UserId(), NotificationId) then
            MyNotifications.Disable(NotificationId)
        else
            MyNotifications.InsertDefault(NotificationId, GetNotificationName(NotificationId), GetNotificationDescription(NotificationId), false);
        Session.LogMessage('0000RFJ', StrSubstNo(UserDisabledNotificationTxt, HostNotification.GetData('NotificationId')), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'IdealPostcodes');
    end;

    procedure NotificationOnConfigure(Notification: Notification)
    begin
        PAGE.Run(PAGE::"Postcode Configuration Page W1");
        DisableNotificationForUser(Notification);
    end;

    procedure NotificationOnDontShowAgain(Notification: Notification)
    begin
        DisableNotificationForUser(Notification);
    end;

    procedure ConfiguredAndSupportedForRecord(CountryOrRegionCode: Code[10]): Boolean
    var
        IPCProvider: Codeunit "IPC Provider";
        PostCodeServiceManager: Codeunit "Postcode Service Manager";
        IsConfigured: Boolean;
    begin
        if not SupportedCountryOrRegionCode(CountryOrRegionCode) then
            exit(false);

        PostCodeServiceManager.IsServiceConfigured(IPCProvider.GetServiceKey(), IsConfigured);
        exit(IsConfigured);
    end;

    local procedure GetNotificationName(NotificationId: Guid): Text[128];
    begin
        case NotificationId of
            GetAwarenessNotificationId():
                exit(AwarenessNotificationNameTxt);
        end;
        exit('');
    end;

    local procedure GetNotificationDescription(NotificationId: Guid): Text;
    begin
        case NotificationId of
            GetAwarenessNotificationId():
                exit(AwarenessNotificationDescriptionTxt);
        end;
        exit('');
    end;

    local procedure GetFieldValue(RecRef: RecordRef; FieldNo: Integer): Text
    var
        FldRef: FieldRef;
    begin
        if TryGetField(RecRef, FieldNo, FldRef) then
            exit(Format(FldRef.Value));
        exit('');
    end;

    local procedure SetFieldValue(RecRef: RecordRef; FieldNo: Integer; Value: Text)
    var
        FldRef: FieldRef;
    begin
        if TryGetField(RecRef, FieldNo, FldRef) then
            FldRef.Value := Value;
    end;

    local procedure TryGetField(RecRef: RecordRef; FieldNo: Integer; var FldRef: FieldRef): Boolean
    begin
        FldRef := RecRef.Field(FieldNo);
        exit(FldRef.Number <> 0);
    end;
}
