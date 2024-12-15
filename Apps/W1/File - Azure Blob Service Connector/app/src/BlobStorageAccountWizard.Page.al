// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

Using System.Environment;

/// <summary>
/// Displays an account that is being registered via the Blob Storage connector.
/// </summary>
page 80101 "Blob Storage Account Wizard"
{
    Caption = 'Setup Azure Blob Storage Account';
    SourceTable = "Blob Storage Account";
    SourceTableTemporary = true;
    Permissions = tabledata "Blob Storage Account" = rimd;
    PageType = NavigatePage;
    Extensible = false;
    Editable = true;

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
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Caption = ' ';
                }
            }

            field(NameField; Rec.Name)
            {
                ApplicationArea = All;
                Caption = 'Account Name';
                ToolTip = 'Specifies the name of the Azure Blob Storage account.';
                ShowMandatory = true;
                NotBlank = true;

                trigger OnValidate()
                begin
                    IsNextEnabled := BlobStorageConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field(StorageAccountNameField; Rec."Storage Account Name")
            {
                ApplicationArea = All;
                Caption = 'Storage Account Name';
                ToolTip = 'Specifies the Azure Storage name.';
                ShowMandatory = true;

                trigger OnValidate()
                begin
                    IsNextEnabled := BlobStorageConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field("Authorization Type"; Rec."Authorization Type")
            {
                ApplicationArea = All;
                ToolTip = 'The way of authorizing used to access the Blob Storage.';
            }

            field(SecretField; Secret)
            {
                ApplicationArea = All;
                Caption = 'Secret';
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the Shared access signature Token or SharedKey.';
                ShowMandatory = true;
            }

            field(ContainerNameField; Rec."Container Name")
            {
                ApplicationArea = All;
                Caption = 'Container Name';
                ToolTip = 'Specifies the container to use of the Storage Blob.';
                ShowMandatory = true;

                trigger OnLookup(var Text: Text): Boolean
                var
                    BlobStorageConnectorImpl: Codeunit "Blob Storage Connector Impl.";
                begin
                    CurrPage.Update();
                    BlobStorageConnectorImpl.LookUpContainer(Rec, Rec."Authorization Type", Secret, Text);
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
                ApplicationArea = All;
                Caption = 'Back';
                ToolTip = 'Back';
                Image = Cancel;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }

            action(Next)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Image = NextRecord;
                Enabled = IsNextEnabled;
                InFooterBar = true;
                ToolTip = 'Next';

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
        BlobStorageConnectorImpl: Codeunit "Blob Storage Connector Impl.";
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