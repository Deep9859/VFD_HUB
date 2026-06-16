import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/security/input_validation_service.dart';
import '../../core/theme/app_form_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/vfd_parameter.dart';

class ParameterEditor extends StatefulWidget {
  final Map<String, List<VfdParameter>> parametersByGroup;
  final Function(int, String) onValueChanged;
  final bool readOnly;

  const ParameterEditor({
    super.key,
    required this.parametersByGroup,
    required this.onValueChanged,
    this.readOnly = false,
  });

  @override
  State<ParameterEditor> createState() => _ParameterEditorState();
}

class _ParameterEditorState extends State<ParameterEditor> {
  final Map<int, TextEditingController> _controllers = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late Map<String, List<VfdParameter>> _filteredParameters;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _updateFilteredParameters();
  }

  @override
  void didUpdateWidget(covariant ParameterEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateFilteredParameters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _updateFilteredParameters();
    });
  }

  void _updateFilteredParameters() {
    if (_searchQuery.isEmpty) {
      _filteredParameters = widget.parametersByGroup;
    } else {
      _filteredParameters = {};
      for (final entry in widget.parametersByGroup.entries) {
        final filteredParams = entry.value.where((param) {
          return param.paramCode.toLowerCase().contains(_searchQuery) ||
              param.paramName.toLowerCase().contains(_searchQuery) ||
              param.description.toLowerCase().contains(_searchQuery);
        }).toList();
        if (filteredParams.isNotEmpty) {
          _filteredParameters[entry.key] = filteredParams;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.tune,
                  color: context.onPrimaryBg,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drive Parameters',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_filteredParameters.values.fold(0, (sum, params) => sum + params.length)} parameters available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.onSurfaceMuted,
                          ),
                    ),
                    if (widget.readOnly)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Chip(
                          label: const Text(
                            'View only — viewer role',
                            style: TextStyle(fontSize: 11),
                          ),
                          backgroundColor: context.warningBg,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Enhanced Search Bar
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.onSurface.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: AppFormStyles.fieldText(context),
            decoration: AppFormStyles.decoration(
              context,
              hintText: 'Search parameters by code or name...',
              prefixIcon: Icon(Icons.search, color: context.cs.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: context.cs.primary),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Results
        if (_filteredParameters.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: context.onSurfaceSubtle,
                ),
                const SizedBox(height: 16),
                Text(
                  'No parameters match your search',
                  style: context.titleStyle?.copyWith(color: context.onSurfaceMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try different keywords or clear the search',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.onSurfaceSubtle,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ..._filteredParameters.entries.map((entry) {
            return _buildParameterGroup(context, entry.key, entry.value);
          }),
      ],
    );
  }

  Widget _buildParameterGroup(
      BuildContext context, String groupName, List<VfdParameter> params) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced Group Header
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.15),
                Theme.of(context).primaryColor.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _getGroupIcon(groupName),
                  color: context.onPrimaryBg,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${params.length} parameter${params.length != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.onSurfaceMuted,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  '${params.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Parameter Cards
        ...params.map((param) => _buildParameterCard(context, param)),
        const SizedBox(height: 20),
      ],
    );
  }

  IconData _getGroupIcon(String groupName) {
    final name = groupName.toLowerCase();
    if (name.contains('basic') || name.contains('general')) {
      return Icons.settings;
    } else if (name.contains('motor')) {
      return Icons.electrical_services;
    } else if (name.contains('advanced') || name.contains('expert')) {
      return Icons.psychology;
    } else if (name.contains('communication') || name.contains('comm')) {
      return Icons.wifi;
    } else if (name.contains('protection') || name.contains('safety')) {
      return Icons.security;
    } else {
      return Icons.tune;
    }
  }

  Widget _buildParameterCard(BuildContext context, VfdParameter param) {
    if (!_controllers.containsKey(param.id)) {
      _controllers[param.id] = TextEditingController(
        text: param.userValue ?? param.defaultValue,
      );
    }

    final controller = _controllers[param.id]!;
    final hasUserValue = param.userValue != null && param.userValue!.isNotEmpty;
    final isModified = hasUserValue && param.userValue != param.defaultValue;

    final cs = context.cs;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isModified ? AppTheme.warning.withOpacity(0.6) : cs.outline,
          width: isModified ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(context.isDarkMode ? 0.25 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Parameter Code and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.15),
                        Theme.of(context).primaryColor.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    param.paramCode,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isModified)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.warningBg,
                          context.warningColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.tintedBorder(context.warningColor),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          size: 14,
                          color: context.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Modified',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Parameter Name
            Text(
              param.paramName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
            ),

            // Parameter Description
            if (param.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                param.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.onSurfaceMuted,
                      height: 1.4,
                    ),
              ),
            ],

            const SizedBox(height: 16),

            // Value Input Field
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: context.onSurface.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller,
                      readOnly: widget.readOnly,
                      style: AppFormStyles.fieldText(context),
                      decoration: AppFormStyles.decoration(
                        context,
                        labelText: 'Parameter Value',
                        hintText: 'Enter value...',
                        suffixText: hasUserValue ? 'Custom' : 'Default',
                        suffixStyle: TextStyle(
                          color: hasUserValue
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isModified
                                ? Theme.of(context).colorScheme.error.withOpacity(0.6)
                                : Theme.of(context).dividerColor,
                            width: isModified ? 2 : 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9a-zA-Z._\-]')),
                      ],
                      onSubmitted: widget.readOnly
                          ? null
                          : (value) {
                              widget.onValueChanged(param.id, value);
                            },
                    ),
                  ),
                ),
                if (!widget.readOnly) ...[
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.successColor,
                        context.successColor.withOpacity(0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: context.successColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.check_circle,
                      color: context.onPrimaryBg,
                      size: 24,
                    ),
                    tooltip: 'Save Parameter',
                    onPressed: () {
                      final value = controller.text.trim();
                      if (value.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please enter a value'),
                            backgroundColor: context.errorColor,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      // Range validation when numeric min/max are defined
                      if (param.minValue.isNotEmpty &&
                          param.maxValue.isNotEmpty &&
                          !InputValidationService.isValidRange(
                              value, param.minValue, param.maxValue)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Value must be between ${param.minValue} and ${param.maxValue}',
                            ),
                            backgroundColor: context.errorColor,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        return;
                      }

                      widget.onValueChanged(param.id, value);
                      FocusScope.of(context).unfocus();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: context.onPrimaryBg),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${param.paramName} saved successfully',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: context.successColor,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ],
              ],
            ),

            // Range and Default Info
            if (param.minValue.isNotEmpty ||
                param.maxValue.isNotEmpty ||
                param.defaultValue.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: context.onSurfaceMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (param.minValue.isNotEmpty ||
                              param.maxValue.isNotEmpty)
                            Text(
                              'Range: ${param.minValue.isEmpty ? 'N/A' : param.minValue} - ${param.maxValue.isEmpty ? 'N/A' : param.maxValue}',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.onSurfaceMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (param.defaultValue.isNotEmpty)
                            Text(
                              'Default: ${param.defaultValue}',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.onSurfaceMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
