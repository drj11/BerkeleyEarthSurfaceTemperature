function sshParallelSubmitHeavy( scheduler, job, props )

sshParallelSubmitCore( scheduler, job, props, 4, 12 );