pageextension 13650 "OIOUBL-Posted Sales Invoices" extends "Posted Sales Invoices"
{
    actions
    {
        addbefore(IncomingDoc)
        {
            separator(Seperator) { }

            action(CreateElectronicInvoices)
            {
                Caption = 'Create Electronic Invoice';
                Tooltip = 'Create an electronic version of the current document.';
                ApplicationArea = Basic, Suite;
                Promoted = True;
                Image = ElectronicDoc;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    SalesInvHeader: Record "Sales Invoice Header";
                begin
                    SalesInvHeader := Rec;
                    SalesInvHeader.SETRECFILTER();

                    REPORT.RUNMODAL(REPORT::"OIOUBL-Create Elec. Invoices", TRUE, FALSE, SalesInvHeader);
                end;
            }
        }
    }
}