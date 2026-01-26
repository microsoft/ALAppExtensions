namespace Microsoft.Sustainability.Setup;

using System.Security.User;

tableextension 6210 "User Setup - TabExt" extends "User Setup"
{
    fields
    {
        field(6210; "Sustainability Manager"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Sustainability Manager';
        }
    }
}