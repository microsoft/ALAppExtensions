pageextension 11515 "Swiss QR-Bill Purchase Journal" extends "Purchase Journal"
{
    layout
    {
        addafter(Description)
        {
            field("Swiss QR-Bill Payment Reference"; "Payment Reference")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the payment reference number.';
                Editable = not "Swiss QR-Bill";
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            group("Swiss QR-Bill")
            {
                Caption = 'QR-Bill';

                action("Swiss QR-Bill Scan")
                {
                    Caption = 'Scan QR-Bill';
                    ToolTip = 'Create a new line from the scanning of QR-bill with an input scanner, or from manual (copy/paste) of the decoded QR-Code text value into a field.';
                    ApplicationArea = All;
                    Image = Import;
                    PromotedCategory = Process;
                    Promoted = true;

                    trigger OnAction()
                    begin
                        SwissQRBillPurchases.NewPurchaseJournalLineFromQRCode(Rec, false);
                    end;
                }
                action("Swiss QR-Bill Import")
                {
                    ApplicationArea = All;
                    Caption = 'Import Scanned QR-Bill File';
                    ToolTip = 'Creates a new line by importing a scanned QR-bill that is saved as a text file.';
                    Image = Import;
                    PromotedCategory = Process;
                    Promoted = true;

                    trigger OnAction()
                    begin
                        SwissQRBillPurchases.NewPurchaseJournalLineFromQRCode(Rec, true);
                    end;
                }
            }
        }
    }

    var
        SwissQRBillPurchases: Codeunit "Swiss QR-Bill Purchases";
}