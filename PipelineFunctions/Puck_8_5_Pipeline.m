%%%%SETUP:
%ONLY TRUE IF USING MIJI:
%1) Before using this function, you must set the MATLAB_JAVA environment
%variable to point to java 8. See also
%https://www.mathworks.com/matlabcentral/answers/130359-how-do-i-change-the-java-virtual-machine-jvm-that-matlab-is-using-on-windows
%For this to work, you must apparently be an administrator on your system,
%and you must run Matlab as an administrator.

%2) If your pucks are a size other than 7x7, you haveto make changes
%both in the yposition and xposition lines, and in the "command" line

%ONLY TRUE IF USING MIJI:
%3) To be able to stitch the pucks from matlab, you need to increase
%matlab's available Java heap space. Within matlab, go to
%Home>Preferences>Matlab>General>Java Heap Memory. 3gb should be fine for
%7x7 images.

%4) Currently, matlab does not make any of the required directories itself,
%although we could easily make them. You have to make the
%C:\users\sgr\pucktmp\PUCKNAME directory, and the C:\Users\sgr\Dropbox (MIT)\Project - SlideSeq\BeadSeq Code\find_roi\InputFolder directory
%And also the C:\Users\sgr\Dropbox (MIT)\Project - SlideSeq\Pucks\PuckBarcodes directory to which BeadSeq will output

%ONLY TRUE IF USING MIJI:
%5) You must download the jheapcl matlab package and put it in the same
%directory as this function is in.

%6) When you are done with the code, you should make the raw data folder in
%Pucks and the InputFolder in find_roi online only via smart sync to save
%hard drive space. You should also delete the pucktmp directory.

%7) A number of paths are hardcoded in the code currently, e.g.
%"C:\Users\sgr\Dropbox (MIT)\Project - SlideSeq\BeadSeq Code\find_roi\helpers\vlfeat-0.9.20\toolbox\"
%in find_roi_stack_fun

%8) The size of the images is curretly hardcoded into find_roi_stack_fun,
%so if you change the size of the images you will have to change it in that
%function also. Look for 'PixelRegion'. The images we use currently should
%be in the range of 1:10660 pixels in each dimension.

%9) The sequencing data with the bead barcodes in it should be in the
%OutputDirectory

%% Initialize
%Set up the paths to all of the various folders with functions in them that
%we will call:
clear all
close all

addpath('C:\Fiji.app\scripts','C:\Users\sgr\Dropbox (MIT)\Project - SlideSeq\BeadSeq Code','C:\Users\sgr\Dropbox (MIT)\Project - SlideSeq\BeadSeq Code\find_roi','C:\Users\sgr\Dropbox (MIT)\Project - SlideSeq\Pucks\PipelineFunctions');
javaaddpath('C:\Program Files\MATLAB\R2017a\java\mij.jar');
javaaddpath(which('MatlabGarbageCollector.jar'))
%We assume that the nd2s have been exported to tiffs in the format:
%DescriptiveNametLYX, where DescriptiveName refers to one run of the microscope,  Y is a letter and X is a number, and L is the
%name of the ligation within that DescriptiveName file series.
%We convert the files to a final output format:
%Puck85 Ligation X Position AB


BarcodeSequence=[1,2,3,4,0,5,0,6,0,7,8,9,10,11,0,12,0,13,0,14]; %this determines how the numerical barcode is built from the ligations. Basically, the constant bases should be 0, and all other bases should be consecutive
FolderWithRawTiffs='C:\Users\sgr\Dropbox (MIT)\Project - SlideSeq\Pucks\Raw\170817 - Puck 8-5\Autoseq Puck 8-5 tiffs\';
FolderWithProcessedTiffs='C:\Users\sgr\Dropbox (MIT)\Project - SlideSeq\Pucks\Processed\';
tmpfolder='C:\Users\sgr\pucktmp\';
%IndexFiles={'primers_n_n-1_n-3_up_up-1_','primers_n-2_n-4_','primers_up-2_up-3_up-4'}; %give the prefixes of each of the files. The next character after should be 't',
%LigationToIndexFileMapping=[1,1,1,1,2,2,1,1,2,2,1,1,1,1,3,3,3,3,3,3];%for ligations 1:20, which file number are the ligations found in?
%for ligations 1:20, which value of t are they, within their file? This
%could also be deduced from the LigationToIndexFileMapping array
%tnumMapping=[1,2,3,4,1,2,5,6,3,4,7,8,9,10,1,2,3,4,5,6];
PuckNames={'Puck_85'}; %give the names of the pucks
OutputFolders={'C:\Users\sgr\Dropbox (MIT)\Project - SlideSeq\Pucks\Barcodes\Puck_85\'};
SequencingFileName={'fei_S3_L001_R1_001.fastq'};
TopBarcodeNum=100000; %when it comes to analyzing barcodes from the illumina data, we only consider the TopBarcodeNum barcodes with the most reads. This should ruoghly be the number of beads on the puck.

for puck=1:length(PuckNames)
    ProcessedImageFolders{puck}=[FolderWithProcessedTiffs,PuckNames{puck},'\'];
end
OutputXIndices=[[1,6]]; %for each puck, give the X indices where it begins and ends

display('Renaming Files');

display('THIS FILE IS A SPECIAL CASE FOR PUCK 85. If you are adapting for future pucks, use the file for puck 8_6 and puck 8_7.')

%% Move files

for ligation=1
    for yposition=1:6
        switch yposition
            case 1
                yposstring='A';
            case 2
                yposstring='B';
            case 3
                yposstring='C';
            case 4
                yposstring='D';
            case 5
                yposstring='E';
            case 6
                yposstring='F';
        end
        for xposition=1:6
            filename=[FolderWithRawTiffs,'puck8-5 - ligation 1 - z06',yposstring,num2str(xposition),'.tif'];
            outputfilename=[tmpfolder,PuckNames{puck},'\','Puck_85_Ligation_01_Position_X_',pad(num2str(xposition),2,'left','0'),'_Y_',pad(num2str(yposition),2,'left','0'),'.tif'];
            copyfile(filename,outputfilename)
        end        
    end
end

for ligation=2:6
    for yposition=1:6
        switch yposition
            case 1
                yposstring='A';
            case 2
                yposstring='B';
            case 3
                yposstring='C';
            case 4
                yposstring='D';
            case 5
                yposstring='E';
            case 6
                yposstring='F';
        end
        for xposition=1:6
            filename=[FolderWithRawTiffs,'puck8-5 - ligations 2-6 - z06',yposstring,num2str(xposition),'t',num2str(ligation-1),'.tif'];
            outputfilename=[tmpfolder,PuckNames{puck},'\','Puck_85_Ligation_',pad(num2str(ligation),2,'left','0'),'_Position_X_',pad(num2str(xposition),2,'left','0'),'_Y_',pad(num2str(yposition),2,'left','0'),'.tif'];
            copyfile(filename,outputfilename);
        end        
    end
end

for ligation=7
    for yposition=1:6
        switch yposition
            case 1
                yposstring='A';
            case 2
                yposstring='B';
            case 3
                yposstring='C';
            case 4
                yposstring='D';
            case 5
                yposstring='E';
            case 6
                yposstring='F';
        end
        for xposition=1:6
            filename=[FolderWithRawTiffs,'puck8-5 - ligation 7 - ',yposstring,num2str(xposition),'.tif'];
            outputfilename=[tmpfolder,PuckNames{puck},'\','Puck_85_Ligation_07_Position_X_',pad(num2str(xposition),2,'left','0'),'_Y_',pad(num2str(yposition),2,'left','0'),'.tif'];
            copyfile(filename,outputfilename)
        end        
    end
end

for ligation=8
    for yposition=1:6
        switch yposition
            case 1
                yposstring='A';
            case 2
                yposstring='B';
            case 3
                yposstring='C';
            case 4
                yposstring='D';
            case 5
                yposstring='E';
            case 6
                yposstring='F';
        end
        for xposition=1:6
            filename=[FolderWithRawTiffs,'puck8-5 - ligation 8 - ',yposstring,num2str(xposition),'.tif'];
            outputfilename=[tmpfolder,PuckNames{puck},'\','Puck_85_Ligation_08_Position_X_',pad(num2str(xposition),2,'left','0'),'_Y_',pad(num2str(yposition),2,'left','0'),'.tif'];            
            copyfile(filename,outputfilename)
        end        
    end
end

for ligation=9:14
    for yposition=1:6
        switch yposition
            case 1
                yposstring='A';
            case 2
                yposstring='B';
            case 3
                yposstring='C';
            case 4
                yposstring='D';
            case 5
                yposstring='E';
            case 6
                yposstring='F';
        end
        for xposition=1:6
            filename=[FolderWithRawTiffs,'puck8-5 - ligations 9-14 - ',yposstring,num2str(xposition),'t',num2str(ligation-8),'.tif'];
            outputfilename=[tmpfolder,PuckNames{puck},'\','Puck_85_Ligation_',pad(num2str(ligation),2,'left','0'),'_Position_X_',pad(num2str(xposition),2,'left','0'),'_Y_',pad(num2str(yposition),2,'left','0'),'.tif'];            
            copyfile(filename,outputfilename);
        end        
    end
end

for ligation=15:20
    for yposition=1:6
        switch yposition
            case 1
                yposstring='A';
            case 2
                yposstring='B';
            case 3
                yposstring='C';
            case 4
                yposstring='D';
            case 5
                yposstring='E';
            case 6
                yposstring='F';
        end
        for xposition=1:6
            filename=[FolderWithRawTiffs,'puck8-5 - ligations 15-20 - ',yposstring,num2str(xposition),'t',num2str(ligation-14),'.tif'];
            outputfilename=[tmpfolder,PuckNames{puck},'\','Puck_85_Ligation_',pad(num2str(ligation),2,'left','0'),'_Position_X_',pad(num2str(xposition),2,'left','0'),'_Y_',pad(num2str(yposition),2,'left','0'),'.tif'];
            copyfile(filename,outputfilename);
        end        
    end
end
%We now open Miji instances and send the command, using parfor, to do the
%stitching
%% Stitching
display('Stitching Images')

for puck=1:length(PuckNames)
thispuckname=PuckNames{puck};
thisinputfolder=[tmpfolder,PuckNames{puck},'\'];
thisoutputfolder=ProcessedImageFolders{puck};

for ligation=1:20

    
    
    %THIS CODE WAS FOR USING MIJI. But there is some memory leak and Miji
    %slows down dramatically by about the 10th ligation.
%    Miji(false); %we don't want to start the FIJI gui
    %https://www.mathworks.com/matlabcentral/fileexchange/47545-mij--running-imagej-and-fiji-within-matlab
    %We got the following command by using the "record" function for macros in ImageJ.
    command=replace(replace(replace('type=[Filename defined position] order=[Defined by filename         ] grid_size_x=6 grid_size_y=6 tile_overlap=30 first_file_index_x=01 first_file_index_y=01 directory=DIRECTORYPATH file_names=PUCKNAME_Ligation_LL_Position_X_{xx}_Y_{yy}.tif output_textfile_name=Ligation_LL.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]','LL',pad(num2str(ligation),2,'left','0')),'PUCKNAME',thispuckname),'DIRECTORYPATH',thisinputfolder);
%    MIJ.run('Grid/Collection stitching',command);
    %We now need to make sure it saves the stitched image. We save to files
    %of the form 'Puck_85_Ligation_1_Stitched'
%    MIJ.selectWindow('Fused');
%    MIJ.run("Save",replace('Tiff..., path=[OUTPUTPATH]','OUTPUTPATH',replace([thisinputfolder,thispuckname,'_Ligation_',pad(num2str(ligation),2,'left','0'),'_Stitched.tif'],'\','\\')));
%    MIJ.run("Close");
%    MIJ.run("Quit");
    
%    movefile([thisinputfolder,thispuckname,'_Ligation_',pad(num2str(ligation),2,'left','0'),'_Stitched.tif'],[thisoutputfolder,thispuckname,'_Ligation_',pad(num2str(ligation),2,'left','0'),'_Stitched.tif'])
    commandfile=fopen('C:\FijiCommand.cmd','w');
    fwrite(commandfile,strcat('C:\Fiji.app\ImageJ-win64.exe --headless --console -macro SlideseqStitch.ijm "',command,'"'));
    fclose(commandfile);
    !C:\FijiCommand
    movefile('C:\Users\sgr\Dropbox (MIT)\Project - SlideSeq\Pucks\PipelineFunctions\PuckOutputTmp.tif',[thisoutputfolder,thispuckname,'_Ligation_',pad(num2str(ligation),2,'left','0'),'_Stitched.tif'])
    %jheapcl
end
end

%Now, issue a command at the command line to change the smart sync status
%of the original input folder

%% Registration
display('Image Registration')

for puck=1:length(PuckNames) %note we are trying to run this overnight without parfor, because we can't figure out why it keeps crashing, and it only crashes for large sized images, and only on puck 8_7
%We now send the command to do the registration with find_roi
    BaseName=[ProcessedImageFolders{puck},PuckNames{puck},'_Ligation_'];
    Suffix='_Stitched';
    find_roi_stack_fun(BaseName,Suffix,8900);
%The outputted files are of the form 
%[BaseName,int2str(mm),' channel ',int2str(k),suffix,' transform.tif']
end
%% Bead calling and sequencing
%we now run Bead_Seq itself. Again, where parallelization is non-trivial in
%Bead_Seq, it is implemented naively using parfor.

display('Base Calling')
    
for puck=1:length(PuckNames) %note we are trying to run this overnight without parfor, because we can't figure out why it keeps crashing, and it only crashes for large sized images, and only on puck 8_7
%We now send the command to do the registration with find_roi

    BaseName=[ProcessedImageFolders{puck},PuckNames{puck},'_Ligation_'];
    suffix='_Stitched';
	[BeadBarcodes BeadLocations BeadImage]=BeadSeqFun(BaseName,suffix,OutputFolders{puck},2,BarcodeSequence,20);
    %The outputted files are of the form 
%[BaseName,int2str(mm),' channel ',int2str(k),suffix,' transform.tif']
end

%% Match Illumina barcodes
for puck=1:length(PuckNames)
    [Base5Barcodes,NegBarcodes,Base5BarcodeCounts]=BeadBarcodeIdentificationFun(OutputFolders{puck},[OutputFolders{puck},SequencingFileName{puck}],TopBarcodeNum);
    load([OutputFolders{puck},'AnalysisOutputs-selected'],'BeadBarcodes','BeadLocations');
    [UniqueBeadBarcodes,BBFirstRef,BBOccCounts]=unique(BeadBarcodes);
    UniqueBeadLocations=BeadLocations(:,BBFirstRef);
    %    [IdentifiedBarcodes,IA,IB]=intersect(BeadBarcodes, Base5Barcodes);
%    [negIdentifiedBarcodes,negIA,negIB]=intersect(BeadBarcodes, NegBarcodes);
    
    paddedBase5Barcodes=zeros(1,ceil(length(Base5Barcodes)/20)*20);
    paddedBase5Barcodes(1:length(Base5Barcodes))=Base5Barcodes;
    paddedNegBarcodes=zeros(1,ceil(length(NegBarcodes)/20)*20);
    paddedNegBarcodes(1:length(NegBarcodes))=NegBarcodes;
    reshapedBase5Barcodes=reshape(paddedBase5Barcodes,ceil(length(Base5Barcodes)/20),20);
    reshapedNegBarcodes=reshape(paddedNegBarcodes,ceil(length(NegBarcodes)/20),20);
    hammingdistancecell={};
    neghammingdistancecell={};
    IndexofBeadBarcodecell={};
    NumNearestBarcodescell={};
    delete(gcp('nocreate'))
    pool=parpool(20);
    
    parfor parnum=1:20 %this could maybe be accelerated by sorting the barcodes?
        localNegBarcodes=reshapedNegBarcodes(:,parnum);
        localBase5Barcodes=reshapedBase5Barcodes(:,parnum);
        localIndexofBeadBarcode=zeros(1,nnz(localBase5Barcodes));
        localNumNearestBarcodes=zeros(1,nnz(localBase5Barcodes)); %when we find the minimum hamming distance, this is the 
        localneghammingdistances=zeros(1,nnz(localNegBarcodes));
        localhammingdistances=zeros(1,nnz(localBase5Barcodes));
    for seq=1:nnz(localBase5Barcodes)
        if seq/1000==ceil(seq/1000)
            disp(['Worker ',num2str(parnum),' is on barcode ',num2str(seq)])
        end
        hammingdistancetmp=cellfun(@(x) dec2base(x,5,14)==dec2base(localBase5Barcodes(seq),5,14), {UniqueBeadBarcodes},'UniformOutput',false);
        tmpsum=sum(cell2mat(hammingdistancetmp),2);        
        [mval,ival]=max(tmpsum);
        localhammingdistances(seq)=14-mval;
        localIndexofBeadBarcode(seq)=ival;
        localNumNearestBarcodes(seq)=sum(tmpsum==mval);
%        if mval==14 && localNumNearestBarcodes(seq)>1
%            display(['problem with barcode ',dec2base(localBase5Barcodes(seq),5,14)]);
%        end
        neghammingdistancetmp=cellfun(@(x) dec2base(x,5,14)==dec2base(localNegBarcodes(seq),5,14), {UniqueBeadBarcodes},'UniformOutput',false);
        localneghammingdistances(seq)=14-max(sum(cell2mat(neghammingdistancetmp),2));
%        hammingdistances(seq)=min(cellfun(@(x) sum(dec2base(abs(x-Base5Barcodes(seq)),5,14)=='1'),{BeadBarcodes},'UniformOutput',false));
%        min=15;
%        for seq2=1:length(BeadBarcodes)
%            num=sum(dec2base(abs(BeadBarcodes(seq2)-Base5Barcodes(seq)),5,14)=='1');
%            if num<min
%                min=num;
%            end
%        end
    end
    hammingdistancecell{parnum}=localhammingdistances;
    neghammingdistancecell{parnum}=localneghammingdistances;
    IndexofBeadBarcodecell{parnum}=localIndexofBeadBarcode;
    NumNearestBarcodescell{parnum}=localNumNearestBarcodes;
    end
    delete(pool);
    numseqs=0;
    for ppp=1:20
        numseqs=numseqs+length(hammingdistancecell{ppp});
    end
    hammingdistances=zeros(1,numseqs);
    neghammingdistances=zeros(1,numseqs);
    IndexofBeadBarcode=zeros(1,numseqs);
    NumNearestBarcodes=zeros(1,numseqs);
    HammingDistanceIndex=1;
    for k=1:20
        hammingdistances(HammingDistanceIndex:(HammingDistanceIndex+length(hammingdistancecell{k})-1))=hammingdistancecell{k};
        neghammingdistances(HammingDistanceIndex:(HammingDistanceIndex+length(neghammingdistancecell{k})-1))=neghammingdistancecell{k};
        IndexofBeadBarcode(HammingDistanceIndex:(HammingDistanceIndex+length(hammingdistancecell{k})-1))=IndexofBeadBarcodecell{k};
        NumNearestBarcodes(HammingDistanceIndex:(HammingDistanceIndex+length(hammingdistancecell{k})-1))=NumNearestBarcodescell{k};
        HammingDistanceIndex=HammingDistanceIndex+length(hammingdistancecell{k});
    end
    save([OutputFolders{puck},PuckNames{puck},'-BarcodesAndHammingDistances.mat'],'hammingdistances','Base5Barcodes','NegBarcodes','neghammingdistances','IndexofBeadBarcode','NumNearestBarcodes','Base5Barcodes','Base5BarcodeCounts');
end


%% Evaluate

%We can now use the Hough transform, and ask what percentage of Hough beads
%also have barcodes, as a way of analyzing what percentage of the beads
%were called. We call the Hough transform and find the centroids, and then
%ask about the fraction of Hough beads with centroids within a radius of a sequenced
%barcode centroid

%We want to produce a plot with the fraction of illumina barcodes that are direct
%matches with a surface bead; one base away from a surface bead; two bases,
%etc., and also for the negative control