// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.AccessControl;
page 30099 "APIV2 - Users Permissions"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'User Permission';
    EntitySetCaption = 'User Permissions';
    EntityName = 'usersPermission';
    EntitySetName = 'usersPermissions';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DataAccessIntent = ReadOnly;
    PageType = API;
    SourceTable = User;
    SourceTableView = where("License Type" = filter('Full User|Limited User|Device Only User|External User|External Administrator|External Accountant'));
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(userSecurityID; Rec."User Security ID")
                {
                    Caption = 'User Security Id';
                }
                field(userName; Rec."User Name")
                {
                    Caption = 'User Name';
                }
                field(fullName; Rec."Full Name")
                {
                    Caption = 'Full Name';
                }
                field(state; Rec.State)
                {
                    Caption = 'State';
                }
                field(expiryDate; Rec."Expiry Date")
                {
                    Caption = 'Expiry Date';
                }
                field(windowsSecurityID; Rec."Windows Security ID")
                {
                    Caption = 'Windows Security Id';
                }
                field(changePassword; Rec."Change Password")
                {
                    Caption = 'Change Password';
                }
                field(licenseType; Rec."License Type")
                {
                    Caption = 'License Type';
                }
                field(authenticationEmail; Rec."Authentication Email")
                {
                    Caption = 'Authentication Email';
                }
                field(contactEmail; Rec."Contact Email")
                {
                    Caption = 'Contact Email';
                }
                field(exchangeIdentifier; Rec."Exchange Identifier")
                {
                    Caption = 'Exchange Identifier';
                }
                field(applicationID; Rec."Application ID")
                {
                    Caption = 'Application Id';
                }
                part(userPermissionSets; "APIV2 - User Permission Sets")
                {
                    Caption = 'User Permission Sets';
                    EntityName = 'userPermissionSet';
                    EntitySetName = 'userPermissionSets';
                    Multiplicity = Many;
                    SubPageLink = "User Security ID" = field("User Security ID");
                }
            }
        }
    }
}