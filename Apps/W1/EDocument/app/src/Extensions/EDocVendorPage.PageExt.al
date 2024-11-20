pageextension 6161 "E-Doc. Vendor Page" extends "Vendor Card"
{
    layout
    {
        addlast(Receiving)
        {
            field("Receive E-Document To"; Rec."Receive E-Document To")
            {
                ApplicationArea = All;
                Caption = 'Receive E-Document To';
                ToolTip = 'Specifies the default purchase document to be generated from received E-document. Users can select either a Purchase Invoice or Purchase Order. This selection does not affect the creation of corrective documents; in both scenarios, the system will generate a Credit Memo.';
            }
            field("E-Document Service Participation Ids"; ParticipantIdCount)
            {
                ApplicationArea = All;
                Caption = 'E-Document Service Participation';
                DrillDown = true;
                Editable = false;
                ToolTip = 'Specifies the vendors participation for the E-Document services.';

                trigger OnDrillDown()
                begin
                    Rec.TestField("No.");
                    ServiceParticipant.RunServiceParticipantPage(Enum::"E-Document Source Type"::Vendor, Rec."No.");
                end;
            }
        }
    }


    var
        ServiceParticipant: Codeunit "Service Participant";
        ParticipantIdCount: Integer;


    trigger OnAfterGetCurrRecord()
    begin
        if Rec."No." <> '' then
            ParticipantIdCount := ServiceParticipant.GetParticipantIdCount(Enum::"E-Document Source Type"::Vendor, Rec."No.");
    end;

}