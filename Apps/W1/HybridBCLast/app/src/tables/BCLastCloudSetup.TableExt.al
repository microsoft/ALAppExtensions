namespace Microsoft.DataMigration.BC;

using Microsoft.DataMigration;

tableextension 4038 "BC Last Cloud Setup" extends "Intelligent Cloud Setup"
{
    fields
    {
        field(40; "Source BC Version"; Decimal)
        {
            DataClassification = SystemMetadata;
            Caption = 'Version of the On Premise BC database';
        }

        field(41; "Use Legacy Upgrade Engine"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
    }
}