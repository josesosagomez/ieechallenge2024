function [normalizedMag, normalizePhase] = normalizeRadarData(data)

    magnitude = abs(data);
    normalizedMagnitude = (magnitude - min(magnitude(:))) / (max(magnitude(:)) - min(magnitude(:)));
    phase = angle(data);
    normalizedMag = normalizedMagnitude;
    normalizePhase = phase;

end