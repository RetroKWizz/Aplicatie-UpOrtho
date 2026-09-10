import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models/account.dart';
import '../../providers.dart';
import 'account_repository.dart';

final accountRepositoryProvider =
    Provider<AccountRepository>((ref) => AccountRepository(ref.watch(apiClientProvider)));

/// Cate comenzi/facturi se aduc pe pagina. Ecranele au liste scurte, cu buton de
/// incarcare a paginii urmatoare - un cont vechi poate avea sute de comenzi.
const accountPageSize = 20;

final ordersProvider = FutureProvider<OrdersPage>(
  (ref) => ref.watch(accountRepositoryProvider).fetchOrders(limit: accountPageSize),
  // retry: null - vezi CLAUDE.md, gotcha 3.
  retry: (retryCount, error) => null,
);

final invoicesProvider = FutureProvider<InvoicesPage>(
  (ref) => ref.watch(accountRepositoryProvider).fetchInvoices(limit: accountPageSize),
  retry: (retryCount, error) => null,
);

final addressesProvider = FutureProvider<List<Address>>(
  (ref) => ref.watch(accountRepositoryProvider).fetchAddresses(),
  retry: (retryCount, error) => null,
);

/// Detaliul unei comenzi. `family` pe id: ecranul de detaliu se deschide pentru o
/// comanda anume, iar cache-ul lui Riverpod pastreaza fiecare comanda separat.
final orderDetailProvider = FutureProvider.family<OrderDetail, int>(
  (ref, id) => ref.watch(accountRepositoryProvider).fetchOrder(id),
  retry: (retryCount, error) => null,
);
