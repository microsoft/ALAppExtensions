namespace Microsoft.DataMigration.GP;

table 40150 "GP Upgrade Settings"
{
    DataClassification = CustomerContent;
    Description = 'GP Upgrade Settings';
    DataPerCompany = false;

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
            OptionMembers = "Background","Same session","Upgrade with rollback";
        }
        field(3; "Upgrade Duration"; Duration)
        {
            DataClassification = CustomerContent;
            Caption = 'Upgrade duration';

            trigger OnValidate()
            begin
                if Rec."Upgrade Mode" <> Rec."Upgrade Mode"::Background then
                    Error(OnlyBackroundCanSpecifyDurationErr);
            end;
        }
        field(5; "Collect All Errors"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Collect all errors';
            InitValue = true;
        }
        field(6; "Data Upgrade Started"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Data Upgrade Started';
        }
    }
    keys
    {
        key(Key1; PrimaryKey)
        {
            Clustered = true;
        }
    }
    internal procedure GetonInsertGPUpgradeSettings(var GPUpgradeSettings: Record "GP Upgrade Settings")
    var
        HybridGPManagement: Codeunit "Hybrid GP Management";
    begin
        if not GPUpgradeSettings.Get() then begin
            GPUpgradeSettings."Upgrade Duration" := HybridGPManagement.GetDefaultJobTimeout();
            GPUpgradeSettings.Insert();
            GPUpgradeSettings.Get();
        end;
    end;

    var
        OnlyBackroundCanSpecifyDurationErr: Label 'You can only set the duration if Upgrade Mode is set to Background';
}