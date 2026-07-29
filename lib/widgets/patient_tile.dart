import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../models/patient.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/breakpoints.dart';
import 'risk_badge.dart';

/// Adapts between a table row (web/tablet) and a tappable list card (phone).
class PatientTile extends StatefulWidget {
  final Patient patient;
  final VoidCallback? onTap;

  const PatientTile({super.key, required this.patient, this.onTap});

  @override
  State<PatientTile> createState() => _PatientTileState();
}

class _PatientTileState extends State<PatientTile> {
  bool _hovering = false;

  String _date(DateTime d) => DateFormat('MMM d').format(d);

  Widget _avatar() {
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.of(context).tealLight,
      child: Text(
        widget.patient.initials,
        style: AppTextStyles.label(context, color: AppColors.of(context).tealPrimary).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;

    if (isPhone(context)) {
      return InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.of(context).card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: AppColors.of(context).line),
          ),
          child: Row(
            children: [
              _avatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: AppTextStyles.body(context, color: AppColors.of(context).ink).copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('Wk ${p.gestationalWeek} · Last visit ${_date(p.lastVisit)}', style: AppTextStyles.caption(context)),
                  ],
                ),
              ),
              RiskBadge(level: p.riskLevel, percent: p.riskPercent),
            ],
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding, vertical: 14),
          color: _hovering ? AppColors.of(context).tealWash : Colors.transparent,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    _avatar(),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        p.name,
                        style: AppTextStyles.body(context, color: AppColors.of(context).ink).copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: Text('${p.age}', style: AppTextStyles.bodySmall(context))),
              Expanded(child: Text('Wk ${p.gestationalWeek}', style: AppTextStyles.bodySmall(context))),
              Expanded(child: Text(_date(p.lastVisit), style: AppTextStyles.bodySmall(context))),
              Expanded(child: RiskBadge(level: p.riskLevel, percent: p.riskPercent)),
              SizedBox(
                width: 72,
                child: TextButton(
                  onPressed: widget.onTap,
                  child: Text('Open →', style: AppTextStyles.link(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
