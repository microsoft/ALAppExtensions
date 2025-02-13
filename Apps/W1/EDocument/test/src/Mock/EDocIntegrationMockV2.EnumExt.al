enumextension 139617 "E-Doc Integration Mock V2" extends "Service Integration"
{

    value(133501; "Mock")
    {
        Implementation = IDocumentSender = "E-Doc. Integration Mock V2", IDocumentReceiver = "E-Doc. Integration Mock V2";
    }
    value(133502; "Mock Sync")
    {
        Implementation = IDocumentSender = "E-Doc. Int Mock No Async", IDocumentReceiver = "E-Doc. Int Mock No Async";
    }

}