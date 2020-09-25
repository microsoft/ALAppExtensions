pageextension 20668 "Whse Ship & Receive Act. BF" extends "Whse Ship & Receive Activities"
{
    layout
    {
        modify("Outbound - Today")
        {
            Visible = false;
        }
        modify("Inbound - Today")
        {
            Visible = false;
        }
    }
}
