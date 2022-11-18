abstract class InvoiceStates {}
class InvoiceInitStates extends InvoiceStates{}
class AppChangeBottomNavBarState extends InvoiceStates{}
class CreateDatabase extends InvoiceStates{}
class InsertDatabase extends InvoiceStates{}
class GetDatabase extends InvoiceStates{}
class AddClient extends InvoiceStates{
  final String clientName;
  final int clientId;
  AddClient(this.clientName ,this.clientId);
}
class WriteClient extends InvoiceStates{
  final String clientName;
  WriteClient(this.clientName);
}
class UpdateFromDatabase extends InvoiceStates{}
class DeleteFromDatabase extends InvoiceStates{}
class ChangeCheckBox extends InvoiceStates{}
class AfterSaveInvoice extends InvoiceStates{}
class Filtering extends InvoiceStates{}
class RemoveItem extends InvoiceStates{}


