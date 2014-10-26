function toolboxGenDoc
% Generate documentation, must run from dir toolbox.
%
% 1) Make sure to update and run toolboxUpdateHeader.m
% 2) Update history.txt appropriately, including w current version
% 3) Update overview.html file with the version/date/link to zip:
%     edit external/m2html/templates/frame-piotr/overview.html
%
% USAGE
%  toolboxGenDoc
%
% INPUTS
%
% OUTPUTS
%
% EXAMPLE
%
% See also
%
% Piotr's Computer Vision Matlab Toolbox      Version NEW
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

% Requires external/m2html to be in path.
cd(fileparts(mfilename('fullpath'))); cd('../');
addpath([pwd '/external/m2html']);

% delete temporary files that should not be part of release
fs={'pngreadc','pngwritec','rjpg8c','wjpg8c','png'};
for i=1:length(fs), delete(['videos/private/' fs{i} '.*']); end

% delete old doc and run m2html
if(exist('doc/','dir')), rmdir('doc/','s'); end
dirs={'channels','classify','detector',...
  'images','filters','matlab','videos'};
m2html('mfiles',dirs,'htmldir','doc','recursive','on','source','off',...
  'template','frame-piotr','index','menu','global','on');

% copy custom menu.html and history file
sDir='external/m2html/templates/';
copyfile([sDir 'menu-for-frame-piotr.html'],'doc/menu.html');
copyfile('external/history.txt','doc/history.txt');

% remove links to private/ in the menu.html files and remove private/ dirs
for i=1:length(dirs)
  name = ['doc/' dirs{i} '/menu.html'];
  fid=fopen(name,'r'); c=fread(fid,'*char')'; fclose(fid);
  c=regexprep(c,'<li>([^<]*[<]?[^<]*)private([^<]*[<]?[^<]*)</li>','');
  fid=fopen(name,'w'); fwrite(fid,c); fclose(fid);
  name = ['doc/' dirs{i} '/private/'];
  if(exist(name,'dir')), rmdir(name,'s'); end
end

% postprocess each html file
for d=1:length(dirs)
  fs=dir(['doc/' dirs{d} '/*.html']); fs={fs.name};
  for j=1:length(fs), postProcess(['doc/' dirs{d} '/' fs{j}]); end
end

end

function postProcess( fName )
lines=readFile(fName);
assert(strcmp(lines{end-1},'</body>') && strcmp(lines{end},'</html>'));
% remove m2html datestamp (if present)
assert(strcmp(lines{end-2}(1:22),'<hr><address>Generated'));
if( strcmp(lines{end-2}(1:25),'<hr><address>Generated on'))
  lines{end-2}=regexprep(lines{end-2}, ...
    '<hr><address>Generated on .* by','<hr><address>Generated by');
end
% remove crossreference information
is=find(strcmp('<!-- crossreference -->',lines)); 
if(~isempty(is)), assert(length(is)==2); lines(is(1):is(2))=[]; end
% insert Google Analytics snippet to end of file
ga={ '';
  '<!-- Start of Google Analytics Code -->';
  '<script type="text/javascript">';
  'var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");';
  'document.write(unescape("%3Cscript src=''" + gaJsHost + "google-analytics.com/ga.js'' type=''text/javascript''%3E%3C/script%3E"));';
  '</script>';
  '<script type="text/javascript">';
  'var pageTracker = _gat._getTracker("UA-4884268-1");';
  'pageTracker._initData();';
  'pageTracker._trackPageview();';
  '</script>';
  '<!-- end of Google Analytics Code -->';
  '' };
lines = [lines(1:end-3); ga; lines(end-2:end)];
% write file
writeFile( fName, lines );
end

function lines = readFile( fName )
fid = fopen( fName, 'rt' ); assert(fid~=-1);
lines=cell(10000,1); n=0;
while( 1 )
  n=n+1; lines{n}=fgetl(fid);
  if( ~ischar(lines{n}) ), break; end
end
fclose(fid); n=n-1; lines=lines(1:n);
end

function writeFile( fName, lines )
fid = fopen( fName, 'w' );
for i=1:length(lines); fprintf( fid, '%s\r\n', lines{i} ); end
fclose(fid);
end
