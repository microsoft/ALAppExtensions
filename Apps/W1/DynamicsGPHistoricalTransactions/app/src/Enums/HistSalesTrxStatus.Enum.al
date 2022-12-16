enum 40001 "Hist. Sales Trx. Status"
{
    Extensible = true;

    value(0; "Unknown") { Caption = 'Unknown'; }
    value(1; New) { Caption = 'New'; }
    value(2; "Ready to Print Pick Ticket") { Caption = 'Ready to Print Pick Ticket'; }
    value(3; "Unconfirmed Pick") { Caption = 'Unconfirmed Pick'; }
    value(4; "Ready to Print Pack Slip") { Caption = 'Ready to Print Pack Slip'; }
    value(5; "Unconfirmed Pack") { Caption = 'Unconfirmed Pack'; }
    value(6; "Shipped") { Caption = 'Shipped'; }
    value(7; "Ready to Post") { Caption = 'Ready to Post'; }
    value(8; "In Process") { Caption = 'In Process'; }
    value(9; "Complete") { Caption = 'Complete'; }
}