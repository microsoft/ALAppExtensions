namespace Microsoft.Sustainability.Account;

using Microsoft.Finance.GeneralLedger.Account;

tableextension 6227 "Sust. G/L Account" extends "G/L Account"
{
    fields
    {
        field(6210; "Default Sust. Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            Caption = 'Default Sust. Account';

            trigger OnValidate()
            var
                SustainabilityAccount: Record "Sustainability Account";
            begin
                if Rec."Default Sust. Account" <> '' then begin
                    SustainabilityAccount.Get(Rec."Default Sust. Account");

                    SustainabilityAccount.CheckAccountReadyForPosting();
                    SustainabilityAccount.TestField("Direct Posting", true);
                end;
            end;
        }
    }
}