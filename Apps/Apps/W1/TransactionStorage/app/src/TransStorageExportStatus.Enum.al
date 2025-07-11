namespace System.DataAdministration;

enum 6201 "Trans. Storage Export Status"
{
    Extensible = false;

    value(0; None) { }
    value(1; "Scheduled") { }
    value(2; "Started") { }
    value(3; "Completed") { }
    value(4; "Failed") { }
}