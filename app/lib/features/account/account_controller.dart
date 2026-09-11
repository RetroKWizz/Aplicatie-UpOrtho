import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models/account.dart';
import '../../providers.dart';
import '../auth/auth_controller.dart';
import 'account_repository.dart';

final accountRepositoryProvider =
    Provider<AccountRepository>((ref) => AccountRepository(ref.watch(apiClientProvider)));

/// Cate comenzi/facturi se aduc pe pagina. Ecranele au liste scurte, cu buton de
/// incarcare a paginii urmatoare - un cont vechi poate avea sute de comenzi.
const accountPageSize = 20;

/// Tot ce urmeaza tine de CONT, deci fiecare provider asteapta intai
/// `authControllerProvider.future`.
///
/// `ref.watch` (nu `ref.read`) il leaga de starea de autentificare pe toata durata
/// lui: orice tranzitie - restaurare terminata, login, logout, **alt cont pe acelasi
/// telefon** - il reconstruieste si cere datele din nou.
///
/// Fara asta, Riverpod pastreaza valoarea in cache cat traieste containerul si nimic
/// nu o invalida la schimbarea de utilizator: al doilea cont vedea comenzile,
/// facturile si adresele primului. S-a intamplat, pe staging, cu doua conturi reale.
/// Aceeasi regula ca la `homeControllerProvider` si `imageHeadersProvider`.
final ordersProvider = FutureProvider<OrdersPage>(
  (ref) async {
    await ref.watch(authControllerProvider.future);
    return ref.read(accountRepositoryProvider).fetchOrders(limit: accountPageSize);
  },
  // retry: null - vezi CLAUDE.md, gotcha 3.
  retry: (retryCount, error) => null,
);

final invoicesProvider = FutureProvider<InvoicesPage>(
  (ref) async {
    await ref.watch(authControllerProvider.future);
    return ref.read(accountRepositoryProvider).fetchInvoices(limit: accountPageSize);
  },
  retry: (retryCount, error) => null,
);

final addressesProvider = FutureProvider<List<Address>>(
  (ref) async {
    await ref.watch(authControllerProvider.future);
    return ref.read(accountRepositoryProvider).fetchAddresses();
  },
  retry: (retryCount, error) => null,
);

/// Detaliul unei comenzi. `family` pe id: ecranul de detaliu se deschide pentru o
/// comanda anume, iar cache-ul lui Riverpod pastreaza fiecare comanda separat.
final orderDetailProvider = FutureProvider.family<OrderDetail, int>(
  (ref, id) async {
    await ref.watch(authControllerProvider.future);
    return ref.read(accountRepositoryProvider).fetchOrder(id);
  },
  retry: (retryCount, error) => null,
);
