import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:a4_iot/domain/entities/proms.dart';
import 'package:a4_iot/domain/entities/users.dart';
import 'package:a4_iot/presentation/controllers/proms.dart' as proms_ctrl;
import 'package:a4_iot/presentation/controllers/users.dart';
import 'package:a4_iot/presentation/widget/student_row_item.dart';

final filteredPromsProvider = FutureProvider<List<Proms>>((ref) async {
  final currentUser = await ref.watch(usersProvider.future);
  final allProms = await ref.watch(proms_ctrl.allPromsProvider.future);

  final status = currentUser.status.toLowerCase();
  if (status == 'teacher' || status == 'instructor' || status == 'admin') {
    return allProms;
  }

  return allProms.where((p) => p.id == currentUser.promsId).toList();
});

// Provider pour obtenir tous les étudiants disponibles (sans promo ou d'autres promos)
final availableStudentsProvider = FutureProvider.family<List<Users>, String>((ref, currentPromsId) async {
  final allUsers = await ref.watch(allUsersProvider.future);
  
  return allUsers.where((user) {
    final status = user.status.toLowerCase();
    // Filtrer pour ne garder que les étudiants qui ne sont pas dans la promo actuelle
    return status == 'student' && (user.promsId.isEmpty || user.promsId != currentPromsId);
  }).toList();
});

class PromsPageView extends ConsumerStatefulWidget {
  const PromsPageView({super.key});

  @override
  ConsumerState<PromsPageView> createState() => _PromsPageViewState();
}

class _PromsPageViewState extends ConsumerState<PromsPageView> {
  String? _selectedPromsId;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(usersProvider);
    final promsAsync = ref.watch(filteredPromsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Promotions'),
        elevation: 2,
      ),
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text("Erreur: $e")),
          data: (currentUser) {
            final status = currentUser.status.toLowerCase();
            final isStaff = status == 'teacher' || status == 'instructor' || status == 'admin';

            return promsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Erreur: $e")),
              data: (promsList) {
                String? activePromsId;

                if (isStaff) {
                  activePromsId = _selectedPromsId;
                } else {
                  activePromsId = currentUser.promsId;
                }

                return Column(
                  children: [
                    // Sélecteur de promotion horizontal en haut (pour staff)
                    if (isStaff)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.school, 
                                  size: 20, 
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Sélectionner une promotion',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 50,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: promsList.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final promo = promsList[index];
                                  final isSelected = promo.id == _selectedPromsId;

                                  return FilterChip(
                                    label: Text(promo.name),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedPromsId = selected ? promo.id : null;
                                      });
                                    },
                                    checkmarkColor: Colors.white,
                                    selectedColor: Theme.of(context).primaryColor,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Contenu principal
                    Expanded(
                      child: activePromsId == null || activePromsId.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Sélectionnez une promotion",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _buildStudentList(activePromsId, isStaff),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      // FloatingActionButton pour ajouter un étudiant (CRUD visible ici)
      floatingActionButton: userAsync.maybeWhen(
        data: (user) {
          final status = user.status.toLowerCase();
          final isStaff = status == 'teacher' || status == 'instructor' || status == 'admin';
          
          if (isStaff && _selectedPromsId != null) {
            return FloatingActionButton.extended(
              onPressed: () => _showAddExistingStudentDialog(context, _selectedPromsId!),
              icon: const Icon(Icons.person_add),
              label: const Text('Ajouter à la promo'),
            );
          }
          return null;
        },
        orElse: () => null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildStudentList(String promsId, bool isStaff) {
    final studentsAsync = ref.watch(studentsByPromsIdProvider(promsId));
    final currentPromAsync = ref.watch(proms_ctrl.promsByIdProvider(promsId));

    return currentPromAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Erreur: $e")),
      data: (proms) {
        return Column(
          children: [
            // En-tête amélioré
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.school,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proms.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        studentsAsync.maybeWhen(
                          data: (students) {
                            final count = students.where((s) {
                              final status = s.status.toLowerCase();
                              return status != 'teacher' && status != 'instructor' && status != 'admin';
                            }).length;
                            return Text(
                              '$count étudiant${count > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            );
                          },
                          orElse: () => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Liste des étudiants avec scroll
            Expanded(
              child: studentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text("Erreur: $e"),
                    ],
                  ),
                ),
                data: (students) {
                  // Filtrer les étudiants
                  final filteredStudents = students.where((s) {
                    final status = s.status.toLowerCase();
                    return status != 'teacher' && status != 'instructor' && status != 'admin';
                  }).toList();

                  if (filteredStudents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Aucun étudiant",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 18,
                            ),
                          ),
                          if (isStaff) ...[
                            const SizedBox(height: 8),
                            Text(
                              "Cliquez sur + pour en ajouter",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredStudents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return StudentRowItem(
                        firstName: student.firstName,
                        lastName: student.lastName,
                        avatarUrl: student.avatarUrl,
                        isPresent: true,
                        onEdit: isStaff
                            ? () => _showEditStudentDialog(context, promsId, student)
                            : null,
                        onDelete: isStaff
                            ? () => _showRemoveFromPromoDialog(context, promsId, student)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // === AJOUTER UN ÉTUDIANT EXISTANT À LA PROMO ===
  void _showAddExistingStudentDialog(BuildContext context, String promsId) {
    final availableStudentsAsync = ref.watch(availableStudentsProvider(promsId));
    final TextEditingController searchController = TextEditingController();
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.person_add, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              const Text('Ajouter un étudiant'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Rechercher',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: availableStudentsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Erreur: $e')),
                    data: (students) {
                      final filteredStudents = students.where((s) {
                        final fullName = '${s.firstName} ${s.lastName}'.toLowerCase();
                        return searchQuery.isEmpty || fullName.contains(searchQuery);
                      }).toList();

                      if (filteredStudents.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                searchQuery.isEmpty
                                    ? 'Aucun étudiant disponible'
                                    : 'Aucun résultat',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: student.avatarUrl.isNotEmpty
                                  ? NetworkImage(student.avatarUrl)
                                  : null,
                              child: student.avatarUrl.isEmpty
                                  ? Text(student.firstName[0].toUpperCase())
                                  : null,
                            ),
                            title: Text('${student.firstName} ${student.lastName}'),
                            subtitle: Text(
                              student.promsId.isEmpty
                                  ? 'Sans promotion'
                                  : 'Autre promotion',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            trailing: const Icon(Icons.add_circle_outline),
                            onTap: () async {
                              try {
                                final supabase = ref.read(supabaseProvider);
                                await supabase.from('users').update({
                                  'proms_id': promsId,
                                }).eq('auth_user_id', student.id);

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle, color: Colors.white),
                                          const SizedBox(width: 12),
                                          Text('${student.firstName} ${student.lastName} ajouté à la promo'),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  ref.invalidate(studentsByPromsIdProvider(promsId));
                                  ref.invalidate(availableStudentsProvider(promsId));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }

  // === MODIFIER UN ÉTUDIANT (INFOS + PROMO) ===
  void _showEditStudentDialog(BuildContext context, String currentPromoId, Users student) {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(text: student.firstName);
    final lastNameController = TextEditingController(text: student.lastName);
    String? selectedPromoId = student.promsId;
    final promsAsync = ref.watch(proms_ctrl.allPromsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            const Text('Modifier l\'étudiant'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                promsAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Erreur: $e'),
                  data: (allPromos) => StatefulBuilder(
                    builder: (context, setState) => DropdownButtonFormField<String>(
                      value: selectedPromoId,
                      decoration: const InputDecoration(
                        labelText: 'Promotion',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Aucune promotion'),
                        ),
                        ...allPromos.map((promo) => DropdownMenuItem<String>(
                          value: promo.id,
                          child: Text(promo.name),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedPromoId = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                final supabase = ref.read(supabaseProvider);
                
                await supabase.from('users').update({
                  'first_name': firstNameController.text,
                  'last_name': lastNameController.text,
                  'proms_id': selectedPromoId,
                }).eq('auth_user_id', student.id);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Étudiant modifié avec succès'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  ref.invalidate(studentsByPromsIdProvider(currentPromoId));
                  if (selectedPromoId != null && selectedPromoId != currentPromoId) {
                    ref.invalidate(studentsByPromsIdProvider(selectedPromoId!));
                  }
                  ref.invalidate(availableStudentsProvider(currentPromoId));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  // === RETIRER DE LA PROMO ===
  void _showRemoveFromPromoDialog(BuildContext context, String promsId, Users student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Text('Retirer de la promotion'),
          ],
        ),
        content: Text(
          'Voulez-vous retirer ${student.firstName} ${student.lastName} de cette promotion ?\n\nL\'étudiant sera accessible depuis d\'autres promotions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                final supabase = ref.read(supabaseProvider);
                await supabase.from('users').update({
                  'proms_id': null,
                }).eq('auth_user_id', student.id);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Étudiant retiré de la promotion'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  ref.invalidate(studentsByPromsIdProvider(promsId));
                  ref.invalidate(availableStudentsProvider(promsId));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }
}
