export interface PainPhotoFindings {
  hasVisibleSwelling: boolean;
  hasBruising: boolean;
  hasRedness: boolean;
  summaryText: string;
}

export async function analyzePainPhoto(photoUrl: string | undefined): Promise<PainPhotoFindings | null> {
  if (!photoUrl) return null;

  // TODO: integrate Qwen Vision. Keep conservative to avoid over-triage from stub.
  return {
    hasVisibleSwelling: false,
    hasBruising: false,
    hasRedness: false,
    summaryText: 'No automated image analysis available yet; photo provided by user.',
  };
}

