// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

page 4002 "Hybrid Product Types"
{
    Caption = 'Cloud Migration Product Types';
    SourceTable = "Hybrid Product Type";
    SourceTableTemporary = true;
    PageType = List;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Products)
            {
                field("Display Name"; Rec."Display Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The display name of the source product.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        CustomMigrationProvider: Enum "Custom Migration Provider";
        CurrentOrdinal: Integer;
    begin
        HybridCloudManagement.OnGetHybridProductType(Rec);
        foreach CurrentOrdinal in Enum::"Custom Migration Provider".Ordinals() do begin
            CustomMigrationProvider := Enum::"Custom Migration Provider".FromInteger(CurrentOrdinal);
            InsertCustomMigrationProvider(CustomMigrationProvider);
        end;
    end;

    local procedure InsertCustomMigrationProvider(CustomMigrationProvider: Enum "Custom Migration Provider")
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        CustomMigrationProviderInterface: Interface "Custom Migration Provider";
        CurrentLanguage: Integer;
    begin
        if CustomMigrationProvider = Enum::"Custom Migration Provider"::"Custom Migration Provider" then begin
            if not IntelligentCloudSetup.Get() then
                exit;

            if not IntelligentCloudSetup."Custom Migration Enabled" then
                exit;
        end;

        Clear(Rec);

        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(1033); // ENU
        Rec.ID := Format(CustomMigrationProvider.AsInteger(), 0, 9) + '-' + Format(CustomMigrationProvider);
#pragma warning disable AA0139
        Rec.ID := Rec.ID.Replace(' ', '');
#pragma warning restore AA0139
        GlobalLanguage(CurrentLanguage);
        CustomMigrationProviderInterface := CustomMigrationProvider;
        Rec."Display Name" := CustomMigrationProviderInterface.GetDisplayName();
        Rec."App ID" := CustomMigrationProviderInterface.GetAppId();
        Rec."Custom Migration Provider" := CustomMigrationProvider;
        Rec.Insert();
    end;
}

