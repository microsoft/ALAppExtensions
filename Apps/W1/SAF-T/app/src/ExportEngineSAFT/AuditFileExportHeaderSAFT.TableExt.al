tableextension 5284 "Audit File Export Header SAF-T" extends "Audit File Export Header"
{
    fields
    {
        field(5280; "Export Currency Information"; Boolean)
        {
            InitValue = true;
        }
    }
}