// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality that allows super users for on-premises versions to enable or disable encryption, import, export or change the encryption key.
/// </summary>

page 9905 "Data Encryption Management"
{
    Caption = 'Data Encryption Management';
    Extensible = false;
    AccessByPermission = System "Tools, Restore" = X;
    AdditionalSearchTerms = 'data security management';
    ApplicationArea = All;
    Editable = false;
    PageType = Card;
    UsageCategory = Tasks;
    ContextSensitiveHelpPage = 'dev-itpro/developer/devenv-encrypting-data';

    layout
    {
        area(content)
        {
            field(EncryptionEnabledState; IsEncryptionEnabled)
            {
                ApplicationArea = All;
                Caption = 'Encryption Enabled';
                Editable = false;
                ToolTip = 'Specifies if an encryption key exists and is enabled on the Business Central Server.';
            }
            field(EncryptionKeyExistsState; DoesEncryptionKeyExist)
            {
                ApplicationArea = All;
                Caption = 'Encryption Key Exists';
                ToolTip = 'Specifies if an encryption key exists on the Business Central Server.';
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Enable Encryption")
            {
                ApplicationArea = All;
                Caption = 'Enable Encryption';
                Enabled = EnableEncryptionActionEnabled;
                Image = CreateDocument;
                PromotedOnly = true;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Generate an encryption key on the server to enable encryption.';
                Visible = NOT IsSaaS;

                trigger OnAction()
                begin
                    CryptographyManagement.EnableEncryption(false);
                    RefreshEncryptionStatus();
                end;
            }
            action("Import Encryption Key")
            {
                AccessByPermission = System "Tools, Restore" = X;
                ApplicationArea = All;
                Caption = 'Import Encryption Key';
                Image = Import;
                PromotedOnly = true;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Import the encryption key to a server instance from an encryption key file that was exported from another server instance or saved as a copy when the encryption was enabled.';
                Visible = NOT IsSaaS;

                trigger OnAction()
                begin
                    CryptographyManagementImpl.ImportKey();
                    RefreshEncryptionStatus();
                end;
            }
            action("Change Encryption Key")
            {
                AccessByPermission = System "Tools, Restore" = X;
                ApplicationArea = All;
                Caption = 'Change Encryption Key';
                Enabled = ChangeKeyActionEnabled;
                Image = Import;
                PromotedOnly = true;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Change to a different encryption key file.';
                Visible = NOT IsSaaS;

                trigger OnAction()
                begin
                    CryptographyManagementImpl.ChangeKey();
                    RefreshEncryptionStatus();
                end;
            }
            action("Export Encryption Key")
            {
                AccessByPermission = System "Tools, Backup" = X;
                ApplicationArea = All;
                Caption = 'Export Encryption Key';
                Enabled = ExportKeyActionEnabled;
                Image = Export;
                PromotedOnly = true;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Export the encryption key to make a copy of the key or so that it can be imported on another server instance.';
                Visible = NOT IsSaaS;

                trigger OnAction()
                begin
                    CryptographyManagementImpl.ExportKey();
                end;
            }
            action("Disable Encryption")
            {
                AccessByPermission = System "Tools, Restore" = X;
                ApplicationArea = All;
                Caption = 'Disable Encryption';
                Enabled = DisableEncryptionActionEnabled;
                Image = Delete;
                PromotedOnly = true;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Decrypt encrypted data.';
                Visible = NOT IsSaaS;

                trigger OnAction()
                begin
                    CryptographyManagement.DisableEncryption(false);
                    RefreshEncryptionStatus();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        RefreshEncryptionStatus();
    end;

    trigger OnInit()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        IsSaaS := EnvironmentInformation.IsSaaS();
    end;

    var
        CryptographyManagement: Codeunit "Cryptography Management";
        CryptographyManagementImpl: Codeunit "Cryptography Management Impl.";
        IsEncryptionEnabled: Boolean;
        DoesEncryptionKeyExist: Boolean;
        EnableEncryptionActionEnabled: Boolean;
        ChangeKeyActionEnabled: Boolean;
        ExportKeyActionEnabled: Boolean;
        DisableEncryptionActionEnabled: Boolean;
        IsSaaS: Boolean;

    local procedure RefreshEncryptionStatus()
    begin
        IsEncryptionEnabled := EncryptionEnabled();
        DoesEncryptionKeyExist := EncryptionKeyExists();

        EnableEncryptionActionEnabled := not IsEncryptionEnabled;
        ExportKeyActionEnabled := DoesEncryptionKeyExist;
        DisableEncryptionActionEnabled := IsEncryptionEnabled;
        ChangeKeyActionEnabled := DoesEncryptionKeyExist;
    end;
}
