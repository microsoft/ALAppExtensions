// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47064 "SL Upgrade Settings"
{
    Access = Internal;
    Caption = 'SL Upgrade Settings';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    Description = 'SL Upgrade Settings';

    fields
    {
        field(1; PrimaryKey; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Upgrade Mode"; Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = 'Background,Same session,Upgrade with rollback';
            OptionMembers = Background,"Same session","Upgrade with rollback";
        }
        field(3; "Upgrade Duration"; Duration)
        {
            Caption = 'Upgrade duration';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Upgrade Mode" <> Rec."Upgrade Mode"::Background then
                    Error(OnlyBackroundCanSpecifyDurationErr);
            end;
        }
        field(4; "Collect All Errors"; Boolean)
        {
            Caption = 'Collect all errors';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(5; "Data Upgrade Started"; DateTime)
        {
            Caption = 'Data Upgrade Started';
            DataClassification = CustomerContent;
        }
        field(6; "Log All Record Changes"; Boolean)
        {
            Caption = 'Log all record changes';
            DataClassification = CustomerContent;
        }
        field(7; "One Step Upgrade"; Boolean)
        {
            Caption = 'Run upgrade after replication';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(8; "One Step Upgrade Delay"; Duration)
        {
            Caption = 'Delay to run the upgrade after replication';
            DataClassification = CustomerContent;
        }
        field(9; "Replication Completed"; DateTime)
        {
            Caption = 'Replication Completed';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; PrimaryKey)
        {
            Clustered = true;
        }
    }
    internal procedure GetonInsertSLUpgradeSettings(var SLUpgradeSettings: Record "SL Upgrade Settings")
    var
        HybridSLManagement: Codeunit "SL Hybrid Management";
    begin
        if not SLUpgradeSettings.Get() then begin
            SLUpgradeSettings."Upgrade Duration" := HybridSLManagement.GetDefaultJobTimeout();
            SLUpgradeSettings."One Step Upgrade" := false;
            SLUpgradeSettings."One Step Upgrade Delay" := GetUpgradeDelay();
            SLUpgradeSettings.Insert();
            SLUpgradeSettings.Get();
        end;
    end;

    internal procedure GetUpgradeDelay(): Duration
    begin
        exit(60 * 1000); // 60 seconds
    end;

    var
        OnlyBackroundCanSpecifyDurationErr: Label 'You can only set the duration if Upgrade Mode is set to Background';
}
