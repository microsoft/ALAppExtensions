// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.\d "postcode"Postcode Configuration Page"
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using Microsoft.Utilities;
using System.Security.Encryption;

page 10503 "Postcode Configuration Page GB"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Postcode provider configuration page';
    PageType = StandardDialog;
    SourceTable = "Postcode Service Config";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Control1040001)
            {
                ShowCaption = false;
                group(Control1040002)
                {
                    InstructionalText = 'Select address postcode lookup provider.';
                    ShowCaption = false;
                    field(SelectedService; ServiceKeyText)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Address Provider';
                        Editable = false;

                        trigger OnDrillDown()
                        var
                            TempNameValueBuffer: Record "Name/Value Buffer" temporary;
                        begin
                            if PAGE.RunModal(PAGE::"Postcode Service Lookup GB", TempNameValueBuffer) = ACTION::LookupOK then
                                ServiceKeyText := TempNameValueBuffer.Name;
                        end;

                        trigger OnAssistEdit()
                        var
                            TempNameValueBuffer: Record "Name/Value Buffer" temporary;
                        begin
                            if PAGE.RunModal(PAGE::"Postcode Service Lookup GB", TempNameValueBuffer) = ACTION::LookupOK then
                                ServiceKeyText := TempNameValueBuffer.Name;
                        end;

                        trigger OnValidate()
                        begin
                            if (ServiceKeyText <> '') and (not EncryptionEnabled()) then
                                if Confirm(CryptographyManagement.GetEncryptionIsNotActivatedQst()) then
                                    PAGE.RunModal(PAGE::"Data Encryption Management");
                        end;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        PostcodeServiceManager: Codeunit "Postcode Service Manager";
    begin
        if not Rec.FindFirst() then begin
            Rec.Init();
            Rec.Insert();
            ServiceKeyText := DisabledTok;
            Rec.SaveServiceKey(DisabledTok);
        end;
        // If we reopen the page and the service status was
        // changed to invalid for some reason, make sure that we
        // also show this on config page
        if not PostcodeServiceManager.IsConfigured() then begin
            ServiceKeyText := DisabledTok;
            Rec.SaveServiceKey(DisabledTok);
        end;

        PrevValue := Rec.GetServiceKey();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::Cancel then begin
            Rec.SaveServiceKey(PrevValue);
            exit(true);
        end;
        if CloseAction = ACTION::OK then begin
            if not Rec.Get() then
                Rec.Insert();
            Rec.SaveServiceKey(ServiceKeyText);
        end;

        Commit();
    end;

    var
        CryptographyManagement: Codeunit "Cryptography Management";
        PrevValue: Text;
        DisabledTok: Label 'Disabled';
        ServiceKeyText: Text;
}
