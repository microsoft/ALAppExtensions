// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

Using System.Environment;

/// <summary>
/// Displays an account that is being registered via the Blob Storage connector.
/// </summary>
page 4561 "Ext. Blob Stor. Account Wizard"
{
    ApplicationArea = All;
    Caption = 'Setup Azure Blob Storage Account';
    Editable = true;
    Extensible = false;
    PageType = NavigatePage;
    Permissions = tabledata "Ext. Blob Storage Account" = rimd;
    SourceTable = "Ext. Blob Storage Account";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(TopBanner)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible;
                field(NotDoneIcon; MediaResources."Media Reference")
                {
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = ' ', Locked = true;
                }
            }

            field(NameField; Rec.Name)
            {
                Caption = 'Account Name';
                NotBlank = true;
                ShowMandatory = true;
                ToolTip = 'Specifies the name of the Azure Blob Storage account.';

                trigger OnValidate()
                begin
                    IsNextEnabled := BlobStorageConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field(StorageAccountNameField; Rec."Storage Account Name")
            {
                Caption = 'Storage Account Name';
                ShowMandatory = true;

                trigger OnValidate()
                begin
                    IsNextEnabled := BlobStorageConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field("Authorization Type"; Rec."Authorization Type")
            {
            }

            field(SecretField; Secret)
            {
                Caption = 'Secret';
                ExtendedDatatype = Masked;
                ShowMandatory = true;
                ToolTip = 'Specifies the Shared access signature Token or SharedKey.';
            }

            field(ContainerNameField; Rec."Container Name")
            {
                Caption = 'Container Name';
                ShowMandatory = true;
                ToolTip = 'Specifies the container to use of the Storage Blob.';

                trigger OnLookup(var Text: Text): Boolean
                var
                    BlobStorageConnectorImpl: Codeunit "Ext. Blob Sto. Connector Impl.";
                    NewContainerName: Text[2048];
                begin
                    CurrPage.Update();
                    NewContainerName := CopyStr(Text, 1, MaxStrLen(NewContainerName));
                    BlobStorageConnectorImpl.LookUpContainer(Rec, Rec."Authorization Type", Secret, NewContainerName);
                    Text := NewContainerName;
                    exit(true);
                end;

                trigger OnValidate()
                begin
                    IsNextEnabled := BlobStorageConnectorImpl.IsAccountValid(Rec);
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Back)
            {
                Caption = 'Back';
                Image = Cancel;
                InFooterBar = true;
                ToolTip = 'Move to the previous step.';

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }

            action(Next)
            {
                Caption = 'Next';
                Enabled = IsNextEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Move to the next step.';

                trigger OnAction()
                begin
                    BlobStorageConnectorImpl.CreateAccount(Rec, Secret, BlobStorageAccount);
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        BlobStorageAccount: Record "File Account";
        MediaResources: Record "Media Resources";
        BlobStorageConnectorImpl: Codeunit "Ext. Blob Sto. Connector Impl.";
        [NonDebuggable]
        Secret: Text;
        IsNextEnabled: Boolean;
        TopBannerVisible: Boolean;

    trigger OnOpenPage()
    var
        AssistedSetupLogoTok: Label 'ASSISTEDSETUP-NOTEXT-400PX.PNG', Locked = true;
    begin
        Rec.Init();
        Rec.Insert();

        if MediaResources.Get(AssistedSetupLogoTok) and (CurrentClientType() = ClientType::Web) then
            TopBannerVisible := MediaResources."Media Reference".HasValue();
    end;

    internal procedure GetAccount(var FileAccount: Record "File Account"): Boolean
    begin
        if IsNullGuid(BlobStorageAccount."Account Id") then
            exit(false);

        FileAccount := BlobStorageAccount;

        exit(true);
    end;
}