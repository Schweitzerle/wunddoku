import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/domain/catalog/avlon.dart';
import 'package:wunddoku/domain/catalog/exudation.dart';
import 'package:wunddoku/domain/catalog/pain.dart';
import 'package:wunddoku/domain/catalog/tissue_distribution.dart';
import 'package:wunddoku/domain/catalog/wcs_stage.dart';
import 'package:wunddoku/domain/catalog/wound_margin.dart';
import 'package:wunddoku/domain/catalog/wound_pocket.dart';

void main() {
  group('WCS stage', () {
    test('necrosis carries its own condition vocabulary', () {
      expect(WcsStage.black.allows(WcsCondition.necroticDry), isTrue);
      expect(WcsStage.black.allows(WcsCondition.dry), isFalse);
    });

    test('epithelialised skin carries its own condition vocabulary', () {
      expect(WcsStage.pinkRed.allows(WcsCondition.skinNormal), isTrue);
      expect(WcsStage.pinkRed.allows(WcsCondition.wet), isFalse);
    });

    test('the six middle stages use dry/moist/wet', () {
      const middle = [
        WcsStage.blackYellow,
        WcsStage.blackYellowRed,
        WcsStage.yellow,
        WcsStage.redYellow,
        WcsStage.red,
        WcsStage.redPink,
      ];
      for (final stage in middle) {
        expect(stage.allowedConditions, {
          WcsCondition.dry,
          WcsCondition.moist,
          WcsCondition.wet,
        }, reason: '$stage');
      }
    });

    test('an impossible combination cannot be constructed', () {
      expect(
        () => WcsFinding(
          stage: WcsStage.red,
          condition: WcsCondition.necroticDry,
          signsOfInfection: false,
        ),
        throwsArgumentError,
      );
    });

    test('infection is independent of the colour stage', () {
      final withInfection = WcsFinding(
        stage: WcsStage.red,
        condition: WcsCondition.moist,
        signsOfInfection: true,
      );
      final withoutInfection = WcsFinding(
        stage: WcsStage.red,
        condition: WcsCondition.moist,
        signsOfInfection: false,
      );
      expect(withInfection, isNot(withoutInfection));
    });
  });

  group('tissue distribution', () {
    test('shares that add up to 100 are accepted', () {
      final distribution = TissueDistribution({
        TissueType.granulation: 60,
        TissueType.fibrin: 40,
      });
      expect(distribution[TissueType.granulation], 60);
      expect(distribution[TissueType.necrosis], 0);
      expect(distribution.presentTypes, [
        TissueType.fibrin,
        TissueType.granulation,
      ]);
    });

    test('a sum below 100 is rejected with a reason', () {
      final shares = {TissueType.granulation: 60, TissueType.fibrin: 30};
      expect(
        TissueDistribution.validate(shares),
        TissueDistributionProblem.sumBelowHundred,
      );
      expect(() => TissueDistribution(shares), throwsArgumentError);
    });

    test('a sum above 100 is rejected with a reason', () {
      expect(
        TissueDistribution.validate({
          TissueType.granulation: 60,
          TissueType.fibrin: 60,
        }),
        TissueDistributionProblem.sumAboveHundred,
      );
    });

    test('a share outside 0..100 is rejected', () {
      expect(
        TissueDistribution.validate({
          TissueType.granulation: 140,
          TissueType.fibrin: -40,
        }),
        TissueDistributionProblem.shareOutOfRange,
      );
    });

    test('equality ignores zero-valued entries', () {
      expect(
        TissueDistribution({TissueType.granulation: 100, TissueType.fibrin: 0}),
        TissueDistribution({TissueType.granulation: 100}),
      );
    });
  });

  group('wound pocket', () {
    test('a point finding spans zero hours', () {
      final pocket = WoundPocket(
        from: ClockPosition(3),
        to: ClockPosition(3),
        depthCm: 1.5,
      );
      expect(pocket.isPoint, isTrue);
      expect(pocket.spanHours, 0);
      expect(pocket.coveredPositions.map((p) => p.value), [3]);
    });

    test('an arc that crosses twelve takes the short way', () {
      final pocket = WoundPocket(
        from: ClockPosition(10),
        to: ClockPosition(2),
        depthCm: 2,
      );
      expect(pocket.spanHours, 4);
      expect(pocket.crossesTwelve, isTrue);
      expect(pocket.coveredPositions.map((p) => p.value), [10, 11, 12, 1, 2]);
    });

    test('direction matters — the reversed arc is the long way round', () {
      final clockwise = WoundPocket(
        from: ClockPosition(2),
        to: ClockPosition(10),
        depthCm: 2,
      );
      expect(clockwise.spanHours, 8);
      expect(clockwise.crossesTwelve, isFalse);
    });

    test('the example from the source form reads as three hours', () {
      // "Unterminierung, Angabe nach der Uhrmethode (z. B. von 12 h - 3 h)"
      final pocket = WoundPocket(
        from: ClockPosition(12),
        to: ClockPosition(3),
        depthCm: 1,
      );
      expect(pocket.spanHours, 3);
      expect(pocket.coveredPositions.map((p) => p.value), [12, 1, 2, 3]);
    });

    test('twelve o clock is the head direction', () {
      expect(ClockPosition.head.value, 12);
      expect(ClockPosition.feet.value, 6);
    });

    test('positions outside 1..12 are rejected', () {
      expect(() => ClockPosition(0), throwsRangeError);
      expect(() => ClockPosition(13), throwsRangeError);
    });

    test('depth must be positive', () {
      expect(
        () => WoundPocket(
          from: ClockPosition(1),
          to: ClockPosition(2),
          depthCm: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('wound margin', () {
    test('infection applies to the surrounding skin only', () {
      expect(
        MarginArea.edge.allowedFeatures.contains(MarginFeature.infection),
        isFalse,
      );
      expect(
        MarginArea.surroundingSkin.allowedFeatures.contains(
          MarginFeature.infection,
        ),
        isTrue,
      );
    });

    test('a feature outside the area is rejected', () {
      expect(
        MarginFinding.validate(
          area: MarginArea.edge,
          features: {MarginFeature.mycosis},
        ),
        MarginProblem.featureNotAllowedForArea,
      );
    });

    test('normal excludes every other feature', () {
      expect(
        MarginFinding.validate(
          area: MarginArea.edge,
          features: {MarginFeature.normal, MarginFeature.redness},
        ),
        MarginProblem.normalCombinedWithOtherFeature,
      );
    });

    test('several features may be observed at once', () {
      final finding = MarginFinding(
        area: MarginArea.edge,
        features: {MarginFeature.redness, MarginFeature.oedematous},
      );
      expect(finding.features.length, 2);
      expect(finding.isEmpty, isFalse);
    });

    test('an empty finding is a gap, not a statement of normality', () {
      final finding = MarginFinding(area: MarginArea.edge, features: const {});
      expect(finding.isEmpty, isTrue);
      expect(finding.features.contains(MarginFeature.normal), isFalse);
    });
  });

  group('exudation', () {
    test('no exudate cannot carry a kind', () {
      expect(
        () => ExudationFinding(
          amount: ExudateAmount.none,
          kinds: {ExudateKind.serous},
        ),
        throwsArgumentError,
      );
    });

    test('kinds combine', () {
      final finding = ExudationFinding(
        amount: ExudateAmount.moderate,
        kinds: {ExudateKind.serous, ExudateKind.bloody},
      );
      expect(finding.kinds.length, 2);
    });

    test('the dressing state is absent until observed', () {
      final finding = ExudationFinding(
        amount: ExudateAmount.slight,
        kinds: {ExudateKind.serous},
      );
      expect(finding.dressingSaturation, isNull);
    });

    test('dressing saturation is ordered from dry to soaked', () {
      expect(
        DressingSaturation.dressingDry.index <
            DressingSaturation.dressingWetClothingWet.index,
        isTrue,
      );
    });
  });

  group('AVLON', () {
    test('an unassessed dimension stays absent instead of defaulting', () {
      final assessment = AvlonAssessment.empty.withGrade(
        AvlonDimension.venous,
        AvlonGrade.iib,
      );
      expect(assessment[AvlonDimension.venous], AvlonGrade.iib);
      expect(assessment[AvlonDimension.arterial], isNull);
      expect(assessment.isComplete, isFalse);
      expect(assessment.missingDimensions, hasLength(4));
    });

    test('all five dimensions from the audit list are present', () {
      expect(AvlonDimension.values, hasLength(5));
    });

    test('grades carry their written label', () {
      expect(AvlonGrade.iia.label, 'IIa');
      expect(AvlonGrade.values.first.label, 'Ia');
      expect(AvlonGrade.values.last.label, 'IV');
    });
  });

  group('pain', () {
    test('the scale runs from 0 to 10', () {
      expect(PainScore(0).score, 0);
      expect(PainScore(10).score, 10);
      expect(() => PainScore(11), throwsRangeError);
      expect(() => PainScore(-1), throwsRangeError);
    });

    test('a score of zero cannot carry a quality', () {
      expect(
        () => PainFinding(
          score: PainScore.none,
          context: PainContext.duringDressingChange,
          qualities: {PainQuality.burning},
        ),
        throwsArgumentError,
      );
    });

    test('wordings outside the catalogue are kept verbatim', () {
      final finding = PainFinding(
        score: PainScore(6),
        context: PainContext.duringDressingChange,
        qualities: {PainQuality.stabbing},
        additionalQualities: {'ziehend'},
      );
      expect(finding.additionalQualities, {'ziehend'});
    });
  });
}
