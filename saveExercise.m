function saveExercise(radarFrames, radarFramesIQ, numExe, typeExer, state)
    path = typeExer + "\" + state + "_technique\exercise_" + num2str(numExe) + ".mat";
    save(path, "radarFrames", "radarFramesIQ");
end