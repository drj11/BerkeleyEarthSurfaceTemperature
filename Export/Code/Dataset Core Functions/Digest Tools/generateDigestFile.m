function generateDigestFile( fname, generator, dependencies, other )

temperatureGlobals;

if nargin < 4
    other = {};
end

fin = fopen([temperature_data_dir fname], 'rb');

jv=java.security.MessageDigest.getInstance('MD5');

while ~feof(fin);
    A = fread(fin,500000, 'uint8');
    jv.update(A);
end

fclose(fin);

md5=typecast(jv.digest,'uint8');
md5=dec2hex(md5)';
if(size(md5,1))==1 % remote possibility: all hash bytes < 128, so pad:
    md5=[repmat('0',[1 size(md5,2)]); md5];
end
md5=lower(md5(:)');

clear jv;

time = datestr( now(), 'yyyy-mm-ddTHH:MM:SS.FFF' );

fout = fopen([temperature_data_dir fname '.digest'], 'w');

fprintf(fout, ['Generator: ' generator '\n']);
fprintf(fout, ['Generated: ' time '\n']);
fprintf(fout, ['MD5 Hash: ' md5 '\n']);

for k = 1:length( dependencies )
    dp = dependencies{k};
    df = readDigestFile( dp );
   
    dp = strrep(dp, '\', '\\');
    fprintf( fout, ['Dependency: ' df.md5_hash ' ' dp '\n'] ); 
end

for k = 1:length(other)
    fprintf(fout, [other{k} '\n']);
end

fclose(fout);


