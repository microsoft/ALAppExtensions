#if not CLEAN26
#pragma warning disable AS0049, AS0072
codeunit 4786 "Company Creation Wizard"
{
    Permissions = tabledata "Assisted Company Setup Status" = rm;
    Access = Internal;
}
#pragma warning restore AS0049, AS0072
#endif